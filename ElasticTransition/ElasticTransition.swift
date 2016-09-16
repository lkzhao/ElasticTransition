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
  case none, rotate, translateMid, translatePull, translatePush, subtle
}

@objc public protocol Scrollable {
  var superview:UIView! { get }
  var contentOffset:CGPoint { get }
  var bounces:Bool { get set }
}

extension UIScrollView:Scrollable{

}

@objc
public protocol ElasticMenuTransitionDelegate{
  @objc optional var contentLength:CGFloat {get}
  @objc optional var dismissByBackgroundTouch:Bool {get}
  @objc optional var dismissByBackgroundDrag:Bool {get}
  @objc optional var dismissByForegroundDrag:Bool {get}
  @objc optional func elasticTransitionWillDismiss(_ transition:ElasticTransition)
  @objc optional func elasticTransitionDidDismiss(_ transition:ElasticTransition)
}


func avg(_ a:CGFloat, _ b:CGFloat) -> CGFloat{
  return (a+b)/2
}
@available(iOS 7.0, *)
public class ElasticTransition: EdgePanTransition, UIGestureRecognizerDelegate{

  /**
   The curvature of the elastic edge.

   lower radiusFactor means higher curvature
   value is clamped between 0 to 0.5
   */
  public var radiusFactor:CGFloat = 0.5

  /**
   The curvature of the elastic edge in interactive transition
   */
  public var interactiveRadiusFactor:CGFloat?

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
  public var transform:((_ progress:CGFloat, _ view:UIView) -> Void)?

  // Transform Type
  public var transformType:ElasticTransitionBackgroundTransform = .translateMid{
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

  // track using translation or direct touch position
  public var shouldAddGestureRecognizers = true

  var cc:DynamicItem!
  var lc:DynamicItem!
  var animationCenterStiffness:CGFloat {
    return (stiffness + 0.5) * (interactive ? 300 : 180)
  }
  var animationSideStiffness:CGFloat {
    return (stiffness + 0.5) * (interactive ? 200 : 140)
  }
  var animationThreshold:CGFloat {
    return interactive ? 0.1 : 0.5
  }
  var animationDamping:CGFloat {
    return (damping + 0.5) * (interactive ? 30 : 20)
  }
  var contentLength:CGFloat = 0
  var lastPoint:CGPoint = CGPoint.zero
  var stickDistance:CGFloat{
    return sticky ? contentLength * panThreshold : 0
  }

  func finalPoint(_ presenting:Bool? = nil) -> CGPoint{
    let p = presenting ?? self.presenting
    switch edge{
    case .left:
      return p ? CGPoint(x: contentLength, y: dragPoint.y) : CGPoint(x: 0, y: dragPoint.y)
    case .right:
      return p ? CGPoint(x: size.width - contentLength, y: dragPoint.y) : CGPoint(x: size.width, y: dragPoint.y)
    case .bottom:
      return p ? CGPoint(x: dragPoint.x, y: size.height - contentLength) : CGPoint(x: dragPoint.x, y: size.height)
    case .top:
      return p ? CGPoint(x: dragPoint.x, y: contentLength) : CGPoint(x: dragPoint.x, y: 0)
    }
  }

  func translatedPoint() -> CGPoint{
    let initialPoint = self.finalPoint(!self.presenting)
    switch edge{
    case .left, .right:
      return CGPoint(x: max(0,min(size.width,initialPoint.x+translation.x)), y: initialPoint.y)
    case .top,.bottom:
      return CGPoint(x: initialPoint.x, y: max(0,min(size.height,initialPoint.y+translation.y)))
    }
  }


  var pushedControllers:[UIViewController] = []
  var backgroundExitPanGestureRecognizer = UIPanGestureRecognizer()
  var foregroundExitPanGestureRecognizer = UIPanGestureRecognizer()

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if transitioning{
      return false
    }
    if let panGR = gestureRecognizer as? UIPanGestureRecognizer{
      let v = panGR.velocity(in: panGR.view!)
      switch edge{
      case .left:
        return v.x < -abs(v.y)
      case .right:
        return v.x > abs(v.y)
      case .bottom:
        return panGR == foregroundExitPanGestureRecognizer || v.y > abs(v.x)
      case .top:
        return v.y < -abs(v.x)
      }
    }
    return true
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if touch.view!.isKind(of: UISlider.self) {
      return false
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
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if let otherGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer,
        let scrollView = otherGestureRecognizer.view as? Scrollable
        , gestureRecognizer == foregroundExitPanGestureRecognizer && edge == .bottom {
        if self.foregroundScrollView == nil {
            if let superScrollView = scrollView.superview as? UIScrollView {
                self.foregroundScrollView = superScrollView
            } else {
                self.foregroundScrollView = scrollView
            }
        }
        return true;
    }
    return false;
  }

  var foregroundScrollView:Scrollable?
  var foregroundExitStarted:Bool {
     return foregroundStartingLocation != nil
  }
  var foregroundStartingLocation:CGPoint?

  func shouldForegroundDismiss() -> Bool{
    if let vc = pushedControllers.last, let delegate = vc as? ElasticMenuTransitionDelegate {
      return delegate.dismissByForegroundDrag ?? false
    }
    return false
  }
  func handleForegroundOffstagePan(_ pan: UIPanGestureRecognizer){
    if let vc = pushedControllers.last{
      switch (pan.state) {
      case .began, .changed:
        if let startingPoint = foregroundStartingLocation {
          dragPoint = pan.location(in: nil)
          translation = CGPoint(x: dragPoint.x - startingPoint.x, y: dragPoint.y - startingPoint.y)
          update()
          resetTimeout()
        } else if let scrollView = foregroundScrollView , edge == .bottom {
          // if we are recognizing simutaneously with a scrollView and the edge is .Bottom
          // we only trigger the transition when user is dragging down and the scrollView's
          // contentOffset is <= 0
          if !shouldForegroundDismiss() { return }
          let v = pan.velocity(in: pan.view!)
          if v.y > abs(v.x) && scrollView.contentOffset.y <= 0{
            scrollView.bounces = false
            dissmissInteractiveTransition(vc, gestureRecognizer: pan, completion: nil)
            foregroundStartingLocation = pan.location(in: nil)
          }
        } else {
          if !shouldForegroundDismiss() { return }
          dissmissInteractiveTransition(vc, gestureRecognizer: pan, completion: nil)
          foregroundStartingLocation = pan.location(in: nil)
        }
      default:
        if foregroundExitStarted{
          foregroundStartingLocation = nil
          _ = endInteractiveTransition()
        }
      }
    }
  }

  func handleOffstagePan(_ pan: UIPanGestureRecognizer){
    if let vc = pushedControllers.last{
      switch (pan.state) {
      case UIGestureRecognizerState.began:
        dissmissInteractiveTransition(vc, gestureRecognizer: pan, completion: nil)
      default:
        _ = updateInteractiveTransition(gestureRecognizer: pan)
      }
    }
  }

  var animationObserverKey:MotionAnimationObserverKey!
  var needUpdate = false
  public override init(){
    super.init()

    cc = DynamicItem(center: CGPoint.zero)
    lc = DynamicItem(center: CGPoint.zero)
    _ = cc.m_addValueUpdateCallback("center") { [weak self] (values:CGPoint) in
      self?.needUpdate = true
    }
    _ = lc.m_addValueUpdateCallback("center") { [weak self] (values:CGPoint) in
      self?.needUpdate = true
    }
    animationObserverKey = MotionAnimator.sharedInstance.addUpdateObserver(self)

    backgroundExitPanGestureRecognizer.delegate = self
    backgroundExitPanGestureRecognizer.addTarget(self, action:#selector(ElasticTransition.handleOffstagePan(_:)))
    foregroundExitPanGestureRecognizer.delegate = self
    foregroundExitPanGestureRecognizer.addTarget(self, action:#selector(ElasticTransition.handleForegroundOffstagePan(_:)))
  }

  deinit{
    MotionAnimator.sharedInstance.removeUpdateObserverWithKey(animationObserverKey)
  }

  override func update() {
    super.update()
    if container == nil {
        return;
    }
    let ccToPoint:CGPoint, lcToPoint:CGPoint
    let initialPoint = self.finalPoint(!self.presenting)
    let p = (useTranlation && interactive) ? translatedPoint() : dragPoint
    switch edge{
    case .left:
      ccToPoint = CGPoint(x: p.x < contentLength ? p.x : (p.x-contentLength)/3+contentLength, y: dragPoint.y)
      lcToPoint = CGPoint(x: min(contentLength, p.distance(initialPoint) < stickDistance ? initialPoint.x : p.x), y: dragPoint.y)
    case .right:
      let maxX = size.width - contentLength
      ccToPoint = CGPoint(x: p.x > maxX ? p.x : maxX - (maxX - p.x)/3, y: dragPoint.y)
      lcToPoint = CGPoint(x: max(maxX, p.distance(initialPoint) < stickDistance ? initialPoint.x : p.x), y: dragPoint.y)
    case .bottom:
      let maxY = size.height - contentLength
      ccToPoint = CGPoint(x: dragPoint.x, y: p.y > maxY ? p.y : maxY - (maxY - p.y)/3)
      lcToPoint = CGPoint(x: dragPoint.x, y: max(maxY, p.distance(initialPoint) < stickDistance ? initialPoint.y : p.y))
    case .top:
      ccToPoint = CGPoint(x: dragPoint.x, y: p.y < contentLength ? p.y : (p.y-contentLength)/3+contentLength)
      lcToPoint = CGPoint(x: dragPoint.x, y: min(contentLength, p.distance(initialPoint) < stickDistance ? initialPoint.y : p.y))
    }
    cc.m_animate("center", to: ccToPoint, stiffness: animationCenterStiffness, damping: animationDamping, threshold: animationThreshold)
    lc.m_animate("center", to: lcToPoint, stiffness: animationSideStiffness, damping: animationDamping, threshold: animationThreshold)
  }

  func updateShape(){
    if !transitioning{
      return
    }
    backView.layer.zPosition = 0
    frontView.layer.zPosition = 300

    let finalPoint = self.finalPoint(true)
    let initialPoint = self.finalPoint(false)
    let progress = 1 - lc.center.distance(finalPoint) / initialPoint.distance(finalPoint)
    switch edge{
    case .left:
      frontView.frame.origin.x = min(cc.center.x, lc.center.x) - contentLength
      presentationController.shadowMaskLayer.frame = CGRect(x: 0, y: 0, width: lc.center.x, height: size.height)
    case .right:
      frontView.frame.origin.x = max(cc.center.x, lc.center.x)
      presentationController.shadowMaskLayer.frame = CGRect(x: lc.center.x, y: 0, width: size.width - lc.center.x, height: size.height)
    case .bottom:
      frontView.frame.origin.y = max(cc.center.y, lc.center.y)
      presentationController.shadowMaskLayer.frame = CGRect(x: 0, y: lc.center.y, width: size.width, height: size.height - lc.center.y)
    case .top:
      frontView.frame.origin.y = min(cc.center.y, lc.center.y) - contentLength
      presentationController.shadowMaskLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: lc.center.y)
    }
    presentationController.shadowMaskLayer.dragPoint = presentationController.shadowMaskLayer.convert(cc.center, from: container.layer)

    if transform != nil{
      transform!(progress, backView)
    }else{
      // transform backView
      switch transformType{
      case .rotate:
        let scale:CGFloat = min(1, 1 - 0.2 * progress)
        let rotate = max(0, 0.15 * progress)
        let rotateY:CGFloat = edge == .left ? -1.0 : edge == .right ? 1.0 : 0
        let rotateX:CGFloat = edge == .bottom ? -1.0 : edge == .top ? 1.0 : 0
        var t = CATransform3DMakeScale(scale, scale, 1)
        t.m34 = 1.0 / -500;
        t = CATransform3DRotate(t, rotate, rotateX, rotateY, 0.0)
        backView.layer.transform = t
      case .translateMid, .translatePull, .translatePush:
        var x:CGFloat = 0, y:CGFloat = 0
        container.backgroundColor = backView.backgroundColor
        let minFunc = transformType == .translateMid ? avg : transformType == .translatePull ? max : min
        let maxFunc = transformType == .translateMid ? avg : transformType == .translatePull ? min : max
        switch edge{
        case .left:
          x = minFunc(cc.center.x, lc.center.x)
        case .right:
          x = maxFunc(cc.center.x, lc.center.x) - size.width
        case .bottom:
          y = maxFunc(cc.center.y, lc.center.y) - size.height
        case .top:
          y = minFunc(cc.center.y, lc.center.y)
        }
        backView.layer.transform = CATransform3DMakeTranslation(x, y, 0)
      case .subtle:
        var x:CGFloat = 0, y:CGFloat = 0
        switch edge{
        case .left:
          x = avg(cc.center.x, lc.center.x)
        case .right:
          x = avg(cc.center.x, lc.center.x) - size.width
        case .bottom:
          y = avg(cc.center.y, lc.center.y) - size.height
        case .top:
          y = avg(cc.center.y, lc.center.y)
        }
        backView.layer.transform = CATransform3DMakeTranslation(x*0.2, y*0.2, 0)
      default:
        backView.layer.transform = CATransform3DIdentity
      }
    }

    presentationController.overlayView.alpha = progress
    presentationController.updateShadow(progress)

    transitionContext.updateInteractiveTransition(presenting ? progress : 1 - progress)
  }


  public func manuallyPushed(_ viewController:UIViewController){
    if shouldAddGestureRecognizers{
      viewController.view.addGestureRecognizer(foregroundExitPanGestureRecognizer)
    }
    pushedControllers.append(viewController)
  }

  override func setup(){
    super.setup()

    // 1. get content length
//    frontView.layoutIfNeeded()
    switch edge{
    case .left, .right:
      contentLength = frontView.bounds.width
    case .top, .bottom:
      contentLength = frontView.bounds.height
    }
    if let vc = frontViewController as? ElasticMenuTransitionDelegate,
      let vcl = vc.contentLength{
      contentLength = vcl
    }

    // 2. setup shadow and background view
    presentationController.shadowView.frame = container.bounds
    if let frontViewBackgroundColor = frontViewBackgroundColor{
      presentationController.shadowMaskLayer.fillColor = frontViewBackgroundColor.cgColor
    }else{
      presentationController.shadowMaskLayer.fillColor = frontView.backgroundColor?.cgColor
    }
    presentationController.shadowMaskLayer.edge = edge.opposite()
    if let interactiveRadiusFactor = interactiveRadiusFactor , interactive{
      presentationController.shadowMaskLayer.radiusFactor = interactiveRadiusFactor
    } else {
      presentationController.shadowMaskLayer.radiusFactor = radiusFactor
    }

    // 3. setup overlay view
    presentationController.overlayView.frame = container.bounds
    presentationController.overlayView.backgroundColor = overlayColor
    presentationController.overlayView.addGestureRecognizer(backgroundExitPanGestureRecognizer)

    // 4. setup front view
    var rect = container.bounds
    switch edge{
    case .right, .left:
      rect.size.width = contentLength
    case .bottom, .top:
      rect.size.height = contentLength
    }
    frontView.frame = rect
    if shouldAddGestureRecognizers {
      frontView.addGestureRecognizer(foregroundExitPanGestureRecognizer)
    }
//    frontView.layoutIfNeeded()

    // 5. container color
    switch transformType{
    case .translateMid, .translatePull, .translatePush:
      container.backgroundColor = backView.backgroundColor
    default:
      container.backgroundColor = containerColor
    }

    // 6. setup MotionAnimation
    if interactive{
        dragPoint = self.startingPoint ?? dragPoint
    } else {
        dragPoint = self.startingPoint ?? container.center
    }
    let initialPoint = finalPoint(!presenting)
    lc.m_removeAnimationForKey("center")
    cc.m_removeAnimationForKey("center")
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


  override func clean(_ finished:Bool){
    frontView.layer.zPosition = 0
    startingPoint = nil
    if let scrollView = foregroundScrollView{
        scrollView.bounces = true
        foregroundScrollView = nil
    }
    if presenting && finished{
      pushedControllers.append(frontViewController)
    }else if !presenting && finished{
      if let vc = pushedControllers.last{
          if let delegate = vc as? ElasticMenuTransitionDelegate {
              delegate.elasticTransitionDidDismiss?(self)
          }
      }
      _ = pushedControllers.popLast()
      if let vc = pushedControllers.last , shouldAddGestureRecognizers {
        vc.view.addGestureRecognizer(foregroundExitPanGestureRecognizer)
      }
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

    if !presenting{
        if let delegate = pushedControllers.last as? ElasticMenuTransitionDelegate {
            delegate.elasticTransitionWillDismiss?(self)
        }
    }
    lc.m_animate("center", to: finalPoint, stiffness: animationSideStiffness, damping: animationDamping, threshold: animationThreshold)
    cc.m_animate("center", to: finalPoint, stiffness: animationCenterStiffness, damping: animationDamping, threshold: animationThreshold){
      self.cc.center = finalPoint
      self.lc.center = finalPoint
      self.updateShape()
      self.clean(true)
    }
  }

  override func endInteractiveTransition() -> Bool{
    if !transitioning {
        return false
    }
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

  override public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.7
  }
}


extension ElasticTransition:MotionAnimatorObserver{
  public func animatorDidUpdate(_ animator: MotionAnimator, dt: CGFloat) {
    if needUpdate {
      updateShape()
    }
  }
}
