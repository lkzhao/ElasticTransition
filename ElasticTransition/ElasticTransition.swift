/*

 The MIT License (MIT)

 Copyright (c) 2015 Luke Zhao <me@lkzhao.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */

import UIKit
import MotionAnimation

public enum ElasticTransitionBackgroundTransform:Int{
  case None, Rotate, TranslateMid, TranslatePull, TranslatePush, Subtle
}

@available(iOS 8.0, *)
@objc
public protocol ElasticMenuTransitionDelegate{
  optional var contentLength:CGFloat {get}
  optional var dismissByBackgroundTouch:Bool {get}
  optional var dismissByBackgroundDrag:Bool {get}
  optional var dismissByForegroundDrag:Bool {get}
}


func avg(a:CGFloat, _ b:CGFloat) -> CGFloat{
  return (a+b)/2
}
@available(iOS 7.0, *)
public class ElasticTransition: EdgePanTransition, UIGestureRecognizerDelegate{

  override
  public var edge:Edge{
    didSet{
      navigationExitPanGestureRecognizer.edges = [edge.opposite().toUIRectEdge()]
    }
  }
  /**
   The curvature of the elastic edge.

   lower radiusFactor means higher curvature
   value is clamped between 0 to 0.5
   */
  public var radiusFactor:CGFloat = 0.5

  /**
   Determines whether or not the view edge will stick to
   the initial position when dragged.

   **Only effective when doing a interactive transition**
   */
  public var sticky:Bool = true

  /**
   The initial position of the simulated drag when static animation is performed

   i.e. The static animation will behave like user is dragging from this point

   **Only effective when doing a static transition**
   */
  public var startingPoint:CGPoint?

  /**
   The background color of the container when doing the transition

   default:
   ```
   UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 1.0)
   ```
   */
  public var containerColor:UIColor = UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 1.0)

  /**
   The color of the overlay when doing the transition

   default:
   ```
   UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 0.5)
   ```
   */
  public var overlayColor:UIColor = UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 0.5)

  /**
   Whether or not to display the shadow. Will decrease performance.

   default: false
   */
  public var showShadow:Bool = false
  /**
   The shadow color of the container when doing the transition

   default:
   ```
   UIColor(red: 100/255, green: 122/255, blue: 144/255, alpha: 1.0)
   ```
   */
  public var shadowColor:UIColor = UIColor(red: 100/255, green: 122/255, blue: 144/255, alpha: 1.0)

  /**
   The shadow color of the container when doing the transition

   default:
   ```
   UIColor(red: 100/255, green: 122/255, blue: 144/255, alpha: 1.0)
   ```
   */
  public var frontViewBackgroundColor:UIColor?
  /**
   The shadow radius of the container when doing the transition

   default:
   ```
   50
   ```
   */
  public var shadowRadius:CGFloat = 50

  // custom transform function
  public var transform:((progress:CGFloat, view:UIView) -> Void)?

  // Transform Type
  public var transformType:ElasticTransitionBackgroundTransform = .TranslateMid{
    didSet{
      if container != nil{
        container.layoutIfNeeded()
      }
    }
  }

  // track using translation or direct touch position
  public var useTranlation = true


  // damping
  public var damping:CGFloat = 0.2{
    didSet{
      damping = min(1.0, max(0.0, damping))
    }
  }

  // damping
  public var stiffness:CGFloat = 0.2{
    didSet{
      stiffness = min(1.0, max(0.0, stiffness))
    }
  }

  var maskLayer = CALayer()

  var cc:DynamicItem!
  var lc:DynamicItem!
  var animationCenterStiffness:CGFloat {
    return (stiffness + 0.5) * 150
  }
  var animationSideStiffness:CGFloat {
    return (stiffness + 0.5) * 100
  }
  var animationThreshold:CGFloat {
    return interactive ? 0.1 : 0.5
  }
  var animationDamping:CGFloat {
    return (damping + 0.5) * 20
  }
  var contentLength:CGFloat = 0
  var lastPoint:CGPoint = CGPointZero
  var stickDistance:CGFloat{
    return sticky ? contentLength * panThreshold : 0
  }
  var overlayView = UIView()
  var shadowView = UIView()
  var shadowMaskLayer = ElasticShapeLayer()

  func finalPoint(presenting:Bool? = nil) -> CGPoint{
    let p = presenting ?? self.presenting
    switch edge{
    case .Left:
      return p ? CGPointMake(contentLength, dragPoint.y) : CGPointMake(0, dragPoint.y)
    case .Right:
      return p ? CGPointMake(size.width - contentLength, dragPoint.y) : CGPointMake(size.width, dragPoint.y)
    case .Bottom:
      return p ? CGPointMake(dragPoint.x, size.height - contentLength) : CGPointMake(dragPoint.x, size.height)
    case .Top:
      return p ? CGPointMake(dragPoint.x, contentLength) : CGPointMake(dragPoint.x, 0)
    }
  }

  func translatedPoint() -> CGPoint{
    let initialPoint = self.finalPoint(!self.presenting)
    switch edge{
    case .Left, .Right:
      return CGPointMake(max(0,min(size.width,initialPoint.x+translation.x)), initialPoint.y)
    case .Top,.Bottom:
      return CGPointMake(initialPoint.x, max(0,min(size.height,initialPoint.y+translation.y)))
    }
  }


  var pushedControllers:[UIViewController] = []
  var backgroundExitPanGestureRecognizer = UIPanGestureRecognizer()
  var foregroundExitPanGestureRecognizer = UIPanGestureRecognizer()
  var navigationExitPanGestureRecognizer = UIScreenEdgePanGestureRecognizer()

  public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if transitioning{
      return false
    }
    if let panGR = gestureRecognizer as? UIPanGestureRecognizer{
      let v = panGR.velocityInView(panGR.view!)
      switch edge{
      case .Left:
        return v.x < -abs(v.y)
      case .Right:
        return v.x > abs(v.y)
      case .Bottom:
        return panGR == foregroundExitPanGestureRecognizer || v.y > abs(v.x)
      case .Top:
        return v.y < -abs(v.x)
      }
    }
    return true
  }

  public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    if touch.view!.isKindOfClass(UISlider.self) {
      return false
    }
    if gestureRecognizer == navigationExitPanGestureRecognizer{
      return true
    }
    if let vc = pushedControllers.last{
      if let delegate = vc as? ElasticMenuTransitionDelegate {
        if gestureRecognizer==backgroundExitPanGestureRecognizer{
          return delegate.dismissByBackgroundDrag ?? false
        }else if gestureRecognizer==foregroundExitPanGestureRecognizer{
          foregroundScrollView = nil
          foregroundStartingLocation = nil
          return delegate.dismissByForegroundDrag ?? false
        }
      }
    }

    return false;
  }
  public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if let scrollView = otherGestureRecognizer.view as? UIScrollView where otherGestureRecognizer.isKindOfClass(NSClassFromString("UIScrollViewPanGestureRecognizer")!) && gestureRecognizer == foregroundExitPanGestureRecognizer {
      self.foregroundScrollView = scrollView
      return true;
    }
    return false;
  }

  var foregroundScrollView:UIScrollView?
  var foregroundExitStarted:Bool {
     return foregroundStartingLocation != nil
  }
  var foregroundStartingLocation:CGPoint?

  func handleForegroundOffstagePan(pan: UIPanGestureRecognizer){
    if let vc = pushedControllers.last{
      switch (pan.state) {
      case .Began, .Changed:
        if let startingPoint = foregroundStartingLocation {
          dragPoint = pan.locationInView(nil)
          translation = CGPointMake(dragPoint.x - startingPoint.x, dragPoint.y - startingPoint.y)
          update()
        } else if let scrollView = foregroundScrollView where edge == .Bottom {
          // if we are recognizing simutaneously with a scrollView and the edge is .Bottom
          // we only trigger the transition when user is dragging down and the scrollView's
          // contentOffset is <= 0
          let v = pan.velocityInView(pan.view!)
          if v.y > abs(v.x) && scrollView.contentOffset.y <= 0{
            foregroundStartingLocation = pan.locationInView(nil)
            scrollView.bounces = false
            dissmissInteractiveTransition(vc, gestureRecognizer: pan, completion: nil)
          }
        } else {
          foregroundStartingLocation = pan.locationInView(nil)
          dissmissInteractiveTransition(vc, gestureRecognizer: pan, completion: nil)
        }
      default:
        if let scrollView = foregroundScrollView{
          scrollView.bounces = true
        }
        if foregroundExitStarted{
          foregroundStartingLocation = nil
          endInteractiveTransition()
        }
      }
    }
  }

  func handleOffstagePan(pan: UIPanGestureRecognizer){
    if let vc = pushedControllers.last{
      switch (pan.state) {
      case UIGestureRecognizerState.Began:
        if pan == navigationExitPanGestureRecognizer{
          navigation = true
        }
        dissmissInteractiveTransition(vc, gestureRecognizer: pan, completion: nil)
      default:
        updateInteractiveTransition(gestureRecognizer: pan)
      }
    }
  }

  var multiValueObserverKey:MotionAnimationObserverKey!
  public override init(){
    super.init()

    cc = DynamicItem(center: CGPointZero)
    lc = DynamicItem(center: CGPointZero)
    multiValueObserverKey = NSObject.m_addCallbackForAnyValueUpdated([cc:["center"],lc:["center"]]) { _ in
      self.updateShape()
    }

    backgroundExitPanGestureRecognizer.delegate = self
    backgroundExitPanGestureRecognizer.addTarget(self, action:"handleOffstagePan:")
    foregroundExitPanGestureRecognizer.delegate = self
    foregroundExitPanGestureRecognizer.addTarget(self, action:"handleForegroundOffstagePan:")
    navigationExitPanGestureRecognizer.delegate = self
    navigationExitPanGestureRecognizer.addTarget(self, action:"handleOffstagePan:")
    navigationExitPanGestureRecognizer.edges = [edge.opposite().toUIRectEdge()]

    shadowView.layer.addSublayer(shadowMaskLayer)
    let tapGR = UITapGestureRecognizer(target: self, action: "overlayTapped:")
    overlayView.opaque = false
    overlayView.addGestureRecognizer(tapGR)
    shadowView.opaque = false
    shadowView.layer.masksToBounds = false
  }

  deinit{
    NSObject.m_removeMultiValueObserver(multiValueObserverKey)
  }

  func overlayTapped(tapGR:UITapGestureRecognizer){
    if let vc = pushedControllers.last,
      let delegate = vc as? ElasticMenuTransitionDelegate {
      let touchToDismiss = delegate.dismissByBackgroundTouch ?? false
      if touchToDismiss{
        vc.dismissViewControllerAnimated(true, completion:nil)
      }
    }
  }

  override func update() {
    super.update()
    let ccToPoint:CGPoint, lcToPoint:CGPoint
    let initialPoint = self.finalPoint(!self.presenting)
    let p = (useTranlation && interactive) ? translatedPoint() : dragPoint
    switch edge{
    case .Left:
      ccToPoint = CGPointMake(p.x < contentLength ? p.x : (p.x-contentLength)/3+contentLength, dragPoint.y)
      lcToPoint = CGPointMake(min(contentLength, p.distance(initialPoint) < stickDistance ? initialPoint.x : p.x), dragPoint.y)
    case .Right:
      let maxX = size.width - contentLength
      ccToPoint = CGPointMake(p.x > maxX ? p.x : maxX - (maxX - p.x)/3, dragPoint.y)
      lcToPoint = CGPointMake(max(maxX, p.distance(initialPoint) < stickDistance ? initialPoint.x : p.x), dragPoint.y)
    case .Bottom:
      let maxY = size.height - contentLength
      ccToPoint = CGPointMake(dragPoint.x, p.y > maxY ? p.y : maxY - (maxY - p.y)/3)
      lcToPoint = CGPointMake(dragPoint.x, max(maxY, p.distance(initialPoint) < stickDistance ? initialPoint.y : p.y))
    case .Top:
      ccToPoint = CGPointMake(dragPoint.x, p.y < contentLength ? p.y : (p.y-contentLength)/3+contentLength)
      lcToPoint = CGPointMake(dragPoint.x, min(contentLength, p.distance(initialPoint) < stickDistance ? initialPoint.y : p.y))
    }
    cc.m_animate("center", to: ccToPoint, stiffness: animationCenterStiffness, damping: animationDamping, threshold: animationThreshold)
    lc.m_animate("center", to: lcToPoint, stiffness: animationSideStiffness, damping: animationDamping, threshold: animationThreshold)
  }

  func updateShape(){
    if !transitioning{
      return
    }
    backView.layer.zPosition = 0
    overlayView.layer.zPosition = 298
    shadowView.layer.zPosition = 299
    frontView.layer.zPosition = 300

    let finalPoint = self.finalPoint(true)
    let initialPoint = self.finalPoint(false)
    let progress = 1 - lc.center.distance(finalPoint) / initialPoint.distance(finalPoint)
    switch edge{
    case .Left:
      frontView.frame.origin.x = min(cc.center.x, lc.center.x) - contentLength
      shadowMaskLayer.frame = CGRectMake(0, 0, lc.center.x, size.height)
    case .Right:
      frontView.frame.origin.x = max(cc.center.x, lc.center.x)
      shadowMaskLayer.frame = CGRectMake(lc.center.x, 0, size.width - lc.center.x, size.height)
    case .Bottom:
      frontView.frame.origin.y = max(cc.center.y, lc.center.y)
      shadowMaskLayer.frame = CGRectMake(0, lc.center.y, size.width, size.height - lc.center.y)
    case .Top:
      frontView.frame.origin.y = min(cc.center.y, lc.center.y) - contentLength
      shadowMaskLayer.frame = CGRectMake(0, 0, size.width, lc.center.y)
    }
    shadowMaskLayer.dragPoint = shadowMaskLayer.convertPoint(cc.center, fromLayer: container.layer)

    if transform != nil{
      transform!(progress: progress, view: backView)
    }else{
      // transform backView
      switch transformType{
      case .Rotate:
        let scale:CGFloat = min(1, 1 - 0.2 * progress)
        let rotate = max(0, 0.15 * progress)
        let rotateY:CGFloat = edge == .Left ? -1.0 : edge == .Right ? 1.0 : 0
        let rotateX:CGFloat = edge == .Bottom ? -1.0 : edge == .Top ? 1.0 : 0
        var t = CATransform3DMakeScale(scale, scale, 1)
        t.m34 = 1.0 / -500;
        t = CATransform3DRotate(t, rotate, rotateX, rotateY, 0.0)
        backView.layer.transform = t
      case .TranslateMid, .TranslatePull, .TranslatePush:
        var x:CGFloat = 0, y:CGFloat = 0
        container.backgroundColor = backView.backgroundColor
        let minFunc = transformType == .TranslateMid ? avg : transformType == .TranslatePull ? max : min
        let maxFunc = transformType == .TranslateMid ? avg : transformType == .TranslatePull ? min : max
        switch edge{
        case .Left:
          x = minFunc(cc.center.x, lc.center.x)
        case .Right:
          x = maxFunc(cc.center.x, lc.center.x) - size.width
        case .Bottom:
          y = maxFunc(cc.center.y, lc.center.y) - size.height
        case .Top:
          y = minFunc(cc.center.y, lc.center.y)
        }
        backView.layer.transform = CATransform3DMakeTranslation(x, y, 0)
      case .Subtle:
        var x:CGFloat = 0, y:CGFloat = 0
        switch edge{
        case .Left:
          x = avg(cc.center.x, lc.center.x)
        case .Right:
          x = avg(cc.center.x, lc.center.x) - size.width
        case .Bottom:
          y = avg(cc.center.y, lc.center.y) - size.height
        case .Top:
          y = avg(cc.center.y, lc.center.y)
        }
        backView.layer.transform = CATransform3DMakeTranslation(x*0.2, y*0.2, 0)
      default:
        backView.layer.transform = CATransform3DIdentity
      }
    }

    overlayView.alpha = progress

    updateShadow(progress)

    transitionContext.updateInteractiveTransition(presenting ? progress : 1 - progress)
  }


  public func manuallyPushed(viewController:UIViewController){
    viewController.view.addGestureRecognizer(foregroundExitPanGestureRecognizer)
    pushedControllers.append(viewController)
  }

  override func setup(){
    super.setup()

    // 1. get content length
    frontView.layoutIfNeeded()
    switch edge{
    case .Left, .Right:
      contentLength = frontView.bounds.width
    case .Top, .Bottom:
      contentLength = frontView.bounds.height
    }
    if let vc = frontViewController as? ElasticMenuTransitionDelegate,
      let vcl = vc.contentLength{
      contentLength = vcl
    }

    // 2. setup shadow and background view
    shadowView.frame = container.bounds
    if let frontViewBackgroundColor = frontViewBackgroundColor{
      shadowMaskLayer.fillColor = frontViewBackgroundColor.CGColor
    }else if let vc = frontViewController as? UINavigationController,
      let rootVC = vc.childViewControllers.last{
      shadowMaskLayer.fillColor = rootVC.view.backgroundColor?.CGColor
    }else{
      shadowMaskLayer.fillColor = frontView.backgroundColor?.CGColor
    }
    shadowMaskLayer.edge = edge.opposite()
    shadowMaskLayer.radiusFactor = radiusFactor
    container.addSubview(shadowView)


    // 3. setup overlay view
    overlayView.frame = container.bounds
    overlayView.backgroundColor = overlayColor
    overlayView.addGestureRecognizer(backgroundExitPanGestureRecognizer)
    container.addSubview(overlayView)

    // 4. setup front view
    var rect = container.bounds
    switch edge{
    case .Right, .Left:
      rect.size.width = contentLength
    case .Bottom, .Top:
      rect.size.height = contentLength
    }
    frontView.frame = rect
    if navigation{
      frontViewController.navigationController?.view.addGestureRecognizer(navigationExitPanGestureRecognizer)
    }else{
      frontView.addGestureRecognizer(foregroundExitPanGestureRecognizer)
    }
    frontView.layoutIfNeeded()

    // 5. container color
    switch transformType{
    case .TranslateMid, .TranslatePull, .TranslatePush:
      container.backgroundColor = backView.backgroundColor
    default:
      container.backgroundColor = containerColor
    }

    // 6. setup MotionAnimation
    dragPoint = self.startingPoint ?? container.center
    let initialPoint = finalPoint(!presenting)
    cc.center = initialPoint
    lc.center = initialPoint

    // 7. do a initial update (put everything into its place)
    updateShape()

    // if not doing an interactive transition, move the drag point to the final position
    if !interactive{
      dragPoint = finalPoint()
      cc.m_animate("center", to: dragPoint, stiffness: animationCenterStiffness, damping: animationDamping, threshold: animationThreshold)
      lc.m_animate("center", to: dragPoint, stiffness: animationSideStiffness, damping: animationDamping, threshold: animationThreshold){
        self.cc.center = self.dragPoint
        self.lc.center = self.dragPoint
        self.updateShape()
        self.clean(true)
      }
    }
  }

  func updateShadow(progress:CGFloat){
    if showShadow{
      shadowView.layer.shadowColor = shadowColor.CGColor
      shadowView.layer.shadowRadius = shadowRadius
      shadowView.layer.shadowOffset = CGSizeMake(0, 0)
      shadowView.layer.shadowOpacity = Float(progress)
      shadowView.layer.masksToBounds = false
    }else{
      shadowView.layer.shadowColor = nil
      shadowView.layer.shadowRadius = 0
      shadowView.layer.shadowOffset = CGSizeMake(0, 0)
      shadowView.layer.shadowOpacity = 0
      shadowView.layer.masksToBounds = true
    }
  }

  override func clean(finished:Bool){
    frontView.layer.zPosition = 0
    if navigation{
      shadowView.removeFromSuperview()
      overlayView.removeFromSuperview()
    }
    if presenting && finished{
      pushedControllers.append(frontViewController)
    }else if !presenting && finished{
      pushedControllers.popLast()
    }
    super.clean(finished)
  }

  override func cancelInteractiveTransition(){
    super.cancelInteractiveTransition()
    let finalPoint = self.finalPoint(!presenting)

    lc.m_animate("center", to: finalPoint, stiffness: animationSideStiffness, damping: animationDamping, threshold: animationThreshold)
    cc.m_animate("center", to: finalPoint, stiffness: animationCenterStiffness, damping: animationDamping, threshold: animationThreshold){
      self.cc.center = finalPoint
      self.lc.center = finalPoint
      self.updateShape()
      self.clean(false)
    }
  }

  override func finishInteractiveTransition(){
    super.finishInteractiveTransition()
    let finalPoint = self.finalPoint()

    lc.m_animate("center", to: finalPoint, stiffness: animationSideStiffness, damping: animationDamping, threshold: animationThreshold)
    cc.m_animate("center", to: finalPoint, stiffness: animationCenterStiffness, damping: animationDamping, threshold: animationThreshold){
      self.cc.center = finalPoint
      self.lc.center = finalPoint
      self.updateShape()
      self.clean(true)
    }
  }

  override func endInteractiveTransition() -> Bool{
    let finalPoint = self.finalPoint()
    let initialPoint = self.finalPoint(!self.presenting)
    let p = (useTranlation && interactive) ? translatedPoint() : dragPoint

    if (p.distance(initialPoint) >= contentLength * panThreshold) &&
      initialPoint.distance(finalPoint) > p.distance(finalPoint){
      self.finishInteractiveTransition()
      return true
    } else {
      self.cancelInteractiveTransition()
      return false
    }
  }

  override public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.7
  }
}

