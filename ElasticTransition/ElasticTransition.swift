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

enum ElasticTransitionBackgroundTransform{
  case None, Rotate, Translate
}

public protocol ElasticMenuTransitionDelegate{
  /**
   The view containting all the screen content
   
   Requirements:
   * a subview of self.view
   * placed along the edge specified to the transition
   * a **clear** background color
   
   
   Note: when constructing this view, set **self.view.backgroundColor** to be the color you desire. not this view's background color.
   */
  var contentView:UIView! {get}
}

public class ElasticTransition: EdgePanTransition{
  
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
  public var sticky:Bool = false
  
  /**
   The initial position of the simulated drag when static animation is performed
   
   i.e. The static animation will behave like user is dragging from this point
   
   **Only effective when doing a static transition**
   */
  public var origin:CGPoint?
  
  /**
   The background color of the container when doing the transition
   
   default: 
   ```
   UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 1.0)
   ```
   */
  public var containerColor:UIColor? = UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 1.0)
  
  // custom transform function
  public var transform:((progress:CGFloat, view:UIView) -> Void)?
  
  // Use Fancy Transform
  public var fancyTransform = true
  
  // track using translation or direct touch position
  public var useTranlation = true
  
  var menuWidth:CGFloat{
    switch edge{
    case .Left, .Right:
      return contentView.bounds.width
    case .Top, .Bottom:
      return contentView.bounds.height
    }
  }
  
  var maskLayer = ElasticShapeLayer()
  
  var animator:UIDynamicAnimator!
  var cc:DynamicItem!
  var lc:DynamicItem!
  var cb:CustomSnapBehavior!
  var lb:CustomSnapBehavior!
  var contentView:UIView!
  var lastPoint:CGPoint = CGPointZero
  var stickDistance:CGFloat{
    return sticky ? menuWidth * panThreshold : 0
  }
  
  func finalPoint(presenting:Bool? = nil) -> CGPoint{
    let p = presenting ?? self.presenting
    switch edge{
    case .Left:
      return p ? CGPointMake(menuWidth, dragPoint.y) : CGPointMake(0, dragPoint.y)
    case .Right:
      return p ? CGPointMake(size.width - menuWidth, dragPoint.y) : CGPointMake(size.width, dragPoint.y)
    case .Bottom:
      return p ? CGPointMake(dragPoint.x, size.height - menuWidth) : CGPointMake(dragPoint.x, size.height)
    case .Top:
      return p ? CGPointMake(dragPoint.x, menuWidth) : CGPointMake(dragPoint.x, 0)
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
  
  override func update() {
    super.update()
    if cb != nil && lb != nil{
      let initialPoint = self.finalPoint(!self.presenting)
      let p = (useTranlation && interactive) ? translatedPoint() : dragPoint
      switch edge{
      case .Left:
        cb.point = CGPointMake(p.x < menuWidth ? p.x : (p.x-menuWidth)/2+menuWidth, dragPoint.y)
        lb.point = CGPointMake(min(menuWidth, p.distance(initialPoint) < stickDistance ? initialPoint.x : p.x), dragPoint.y)
      case .Right:
        let maxX = size.width - menuWidth
        cb.point = CGPointMake(p.x > maxX ? p.x : maxX - (maxX - p.x)/2, dragPoint.y)
        lb.point = CGPointMake(max(maxX, p.distance(initialPoint) < stickDistance ? initialPoint.x : p.x), dragPoint.y)
      case .Bottom:
        let maxY = size.height - menuWidth
        cb.point = CGPointMake(dragPoint.x, p.y > maxY ? p.y : maxY - (maxY - p.y)/2)
        lb.point = CGPointMake(dragPoint.x, max(maxY, p.distance(initialPoint) < stickDistance ? initialPoint.y : p.y))
      case .Top:
        cb.point = CGPointMake(dragPoint.x, p.y < menuWidth ? p.y : (p.y-menuWidth)/2+menuWidth)
        lb.point = CGPointMake(dragPoint.x, min(menuWidth, p.distance(initialPoint) < stickDistance ? initialPoint.y : p.y))
      }
    }
  }
  
  func updateShape(){
    if animator == nil{
      return
    }
    
    frontView.layer.zPosition = 100
    frontView.layer.mask = maskLayer
    
    let finalPoint = self.finalPoint(true)
    let initialPoint = self.finalPoint(false)
    let progress = 1 - lc.center.distance(finalPoint) / initialPoint.distance(finalPoint)
    switch edge{
    case .Left:
      contentView.frame.origin.x = min(cc.center.x, lc.center.x) - menuWidth
      maskLayer.frame = CGRectMake(0, 0, lc.center.x, size.height)
    case .Right:
      contentView.frame.origin.x = max(cc.center.x, lc.center.x)
      maskLayer.frame = CGRectMake(lc.center.x, 0, size.width - lc.center.x, size.height)
    case .Bottom:
      contentView.frame.origin.y = max(cc.center.y, lc.center.y)
      maskLayer.frame = CGRectMake(0, lc.center.y, size.width, size.height - lc.center.y)
    case .Top:
      contentView.frame.origin.y = min(cc.center.y, lc.center.y) - menuWidth
      maskLayer.frame = CGRectMake(0, 0, size.width, lc.center.y)
    }
    maskLayer.dragPoint = maskLayer.convertPoint(cc.center, fromLayer: container.layer)
    
    if transform != nil{
      transform!(progress: progress, view: backView)
    }else{
      // transform backView
      let scale:CGFloat = min(1, 1 - 0.2 * progress)
      let rotate = max(0, 0.15 * progress)
      let rotateY:CGFloat = edge == .Left ? -1.0 : edge == .Right ? 1.0 : 0
      let rotateX:CGFloat = edge == .Bottom ? -1.0 : edge == .Top ? 1.0 : 0
      var t = CATransform3DMakeScale(scale, scale, 1)
      t.m34 = 1.0 / -500;
      t = CATransform3DRotate(t, rotate, rotateX, rotateY, 0.0)
      if fancyTransform{
        backView.layer.transform = t
      }else{
        backView.layer.transform = CATransform3DIdentity
      }
      backView.frame = container.bounds
      backView.layer.opacity = Float(1 - rotate*5)
    }
  }
  
  override func setup(){
    super.setup()
    if let menuViewController = frontViewController as? ElasticMenuTransitionDelegate{
      contentView = menuViewController.contentView
    }else{
      fatalError("frontViewController must be supplied and must be a ElasticMenuTransitionDelegate")
    }
    toView.layoutIfNeeded()
    container.backgroundColor = containerColor
    maskLayer = ElasticShapeLayer()
    
    maskLayer.edge = edge.opposite()
    maskLayer.radiusFactor = radiusFactor
    if presenting {
      frontView.layer.mask = maskLayer
    }
    setupDynamics()
    if !interactive{
      let duration = self.transitionDuration(transitionContext)
      lb.action = {
        if self.animator != nil && self.animator.elapsedTime() >= duration {
          self.cc.center = self.dragPoint
          self.lc.center = self.dragPoint
          self.updateShape()
          self.clean(true)
        }
      }
      
      dragPoint = self.origin ?? container.center
      dragPoint = finalPoint()
    }
  }
  
  func setupDynamics(){
    animator = UIDynamicAnimator(referenceView: container)
    let initialPoint = finalPoint(!presenting)
    
    cc = DynamicItem(center: initialPoint)
    lc = DynamicItem(center: initialPoint)
    if interactive{
      cb = CustomSnapBehavior(item: cc, point: dragPoint, useSnap: true)
      cb.damping = 0.2
      lb = CustomSnapBehavior(item: lc, point: dragPoint, useSnap: true)
      lb.damping = 0.5
    }else{
      cb = CustomSnapBehavior(item: cc, point: dragPoint)
      cb.length = 1
      cb.damping = 0.5
      cb.frequency = 2.5
      lb = CustomSnapBehavior(item: lc, point: dragPoint)
      lb.length = 1
      lb.damping = 0.7
      lb.frequency = 2.5
    }
    update()
    cb.action = {
      self.updateShape()
    }
    animator.addBehavior(cb)
    animator.addBehavior(lb)
  }
    
  override func clean(finished:Bool){
    animator.removeAllBehaviors()
    animator = nil
    super.clean(finished)
  }
  
  override func cancelInteractiveTransition(){
    super.cancelInteractiveTransition()
    let finalPoint = self.finalPoint(!self.presenting)
    
    cb.point = finalPoint
    lb.point = finalPoint
    lb.action = {
      if finalPoint.distance(self.cc.center) < 1 &&
         finalPoint.distance(self.lc.center) < 1 &&
        self.lastPoint.distance(self.cc.center) < 0.05{
          self.cc.center = finalPoint
          self.lc.center = finalPoint
          self.updateShape()
          self.clean(false)
      }else{
        self.updateShape()
      }
      self.lastPoint = self.cc.center
    }
  }
  
  override func finishInteractiveTransition(){
    super.finishInteractiveTransition()
    let finalPoint = self.finalPoint()
    
    cb.point = finalPoint
    lb.point = finalPoint
    lb.action = {
      if finalPoint.distance(self.cc.center) < 1 &&
        finalPoint.distance(self.lc.center) < 1 &&
        self.lastPoint.distance(self.cc.center) < 0.05{
          self.cc.center = finalPoint
          self.lc.center = finalPoint
          self.updateShape()
          self.clean(true)
      }else{
        self.updateShape()
      }
      self.lastPoint = self.cc.center
    }
  }
  
  override func endInteractiveTransition(){
    let finalPoint = self.finalPoint()
    let initialPoint = self.finalPoint(!self.presenting)
    let p = (useTranlation && interactive) ? translatedPoint() : dragPoint

    if (p.distance(initialPoint) >= menuWidth * panThreshold) &&
      initialPoint.distance(finalPoint) > p.distance(finalPoint){
      self.finishInteractiveTransition()
    } else {
      self.cancelInteractiveTransition()
    }
  }
}

