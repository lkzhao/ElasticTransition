//
//  ElasticTransition.swift
//  ElasticTransition
//
//  Created by Luke Zhao on 2015-11-30.
//  Copyright © 2015 lukezhao. All rights reserved.
//

import UIKit

protocol ElasticMenuTransitionDelegate{
  var contentView:UIView! {get}
}


extension CGPoint{
  func distance(b:CGPoint)->CGFloat{
    return sqrt(pow(self.x-b.x,2)+pow(self.y-b.y,2));
  }
}

class DynamicItem:NSObject, UIDynamicItem{
  var center: CGPoint = CGPointZero
  var bounds: CGRect = CGRectMake(0, 0, 1, 1)
  var transform: CGAffineTransform = CGAffineTransformIdentity
  init(center:CGPoint) {
    self.center = center
    super.init()
  }
}

class CustomSnapBehavior:UIDynamicBehavior {
  var attachmentBehavior:UIAttachmentBehavior?
  var snapBehavoir:UISnapBehavior?
  
  var length:CGFloat = 0{
    didSet{
      if let ab = attachmentBehavior{
        ab.length = length
      }
    }
  }
  var frequency:CGFloat = 1{
    didSet{
      if let ab = attachmentBehavior{
        ab.frequency = frequency
      }
    }
  }
  var damping:CGFloat = 0{
    didSet{
      if let ab = attachmentBehavior{
        ab.damping = damping
      }else{
        snapBehavoir!.damping = damping
      }
    }
  }
  var point:CGPoint{
    didSet{
      if let ab = attachmentBehavior{
        ab.anchorPoint = point
      }else{
        snapBehavoir!.snapPoint = point
      }
    }
  }
  init(item:UIDynamicItem, point:CGPoint, useSnap:Bool = false) {
    self.point = point
    super.init()
    if useSnap{
      snapBehavoir = UISnapBehavior(item: item, snapToPoint: point)
      addChildBehavior(snapBehavoir!)
    }else{
      attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: point)
      addChildBehavior(attachmentBehavior!)
    }
  }
}

class ElasticTransition: EdgePanTransition{
  var radiusFactor:CGFloat = 0.5
  var sticky:Bool = false
  var origin:CGPoint?
  var containerColor:UIColor? = UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 1.0)
  var transform:((progress:CGFloat, view:UIView) -> Void)?
  var fancyTransform = true
  var useTranlation = true
  
  private var menuWidth:CGFloat{
    switch edge{
    case .Left, .Right:
      return contentView.bounds.width
    case .Top, .Bottom:
      return contentView.bounds.height
    }
  }
  
  private var maskLayer = ElasticShapeLayer()
  
  private var animator:UIDynamicAnimator!
  private var cc:DynamicItem!
  private var lc:DynamicItem!
  private var cb:CustomSnapBehavior!
  private var lb:CustomSnapBehavior!
  private var contentView:UIView!
  private var stickDistance:CGFloat{
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
  private override func clean(finished:Bool){
    animator.removeAllBehaviors()
    animator = nil
    super.clean(finished)
  }
  
  private var lastPoint:CGPoint = CGPointZero
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

class EdgePanTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate{
  var transitionDuration = 0.7
  var panThreshold:CGFloat = 0.2
  var edge:Edge = .Left{
    didSet{
      enterPanGesture.edges = edge.toUIRectEdge()
    }
  }
  var segueIdentifier = "menu"
  var backViewController: UIViewController! {
    didSet {
      backViewController.view.addGestureRecognizer(self.enterPanGesture)
      backViewController.transitioningDelegate = self
      backViewController.modalPresentationStyle = .OverCurrentContext;
    }
  }
  
  var frontViewController: UIViewController! {
    didSet {
      frontViewController.transitioningDelegate = self
      frontViewController.modalPresentationStyle = .OverCurrentContext;
      frontViewController.view.addGestureRecognizer(self.exitPanGesture)
    }
  }
  
  var transitioning = false
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    return !transitioning
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    if touch.view!.isKindOfClass(UISlider.self) {
      return false
    }
    return true;
  }
  

  private var presenting = true
  private var interactive = false
  
  private var container:UIView!
  private var size:CGSize{
    return container.bounds.size
  }
  
  private var frontView:UIView!
  private var backView:UIView!
  private var toView:UIView!
  private var fromView:UIView!
  private var toViewController:UIViewController!
  private var fromViewController:UIViewController!
  private var transitionContext:UIViewControllerContextTransitioning!
  
  private var enterPanGesture: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
  private var exitPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
  
  private var translation:CGPoint = CGPointZero
  private var dragPoint:CGPoint = CGPointZero{
    didSet{
      update()
    }
  }
  
  override init(){
    super.init()
    enterPanGesture.delegate = self
    enterPanGesture.addTarget(self, action:"handleOnstagePan:")
    enterPanGesture.edges = edge.toUIRectEdge()
    exitPanGesture.delegate = self
    exitPanGesture.addTarget(self, action:"handleOffstagePan:")
  }
  
  private func update(){
    
  }
  
  private func setup(){
    transitioning = true
  }
  
  private func clean(finished: Bool){
    // bug: http://openradar.appspot.com/radar?id=5320103646199808
    UIApplication.sharedApplication().keyWindow!.addSubview(finished ? toView : fromView)

    if(!presenting && finished || presenting && !finished){
      frontView.removeFromSuperview()
      self.backView.layer.transform = CATransform3DIdentity
      self.backView.frame = container.bounds
      backViewController.viewDidAppear(true)
    }
    
    transitioning = false
    interactive = false
    transitionContext.completeTransition(finished)
  }
  
  func handleOnstagePan(pan: UIPanGestureRecognizer){
    switch (pan.state) {
    case UIGestureRecognizerState.Began:
      self.interactive = true
      self.backViewController.performSegueWithIdentifier(segueIdentifier, sender: self)
      self.translation = pan.translationInView(container)
      self.dragPoint = pan.locationInView(container)
    case UIGestureRecognizerState.Changed:
      self.translation = pan.translationInView(container)
      self.dragPoint = pan.locationInView(container)
    default:
      endInteractiveTransition()
    }
  }
  
  func handleOffstagePan(pan: UIPanGestureRecognizer){
    switch (pan.state) {
    case UIGestureRecognizerState.Began:
      self.interactive = true
      self.frontViewController.dismissViewControllerAnimated(true, completion: nil)
      self.translation = pan.translationInView(container)
      self.dragPoint = pan.locationInView(container)
    case UIGestureRecognizerState.Changed:
      self.translation = pan.translationInView(container)
      self.dragPoint = pan.locationInView(container)
    default:
      endInteractiveTransition()
    }
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    self.transitionContext = transitionContext
    container = transitionContext.containerView()
    fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    fromView = fromViewController.view
    toView = toViewController.view
    
    if (presenting){
      frontView = toView
      backView = fromView
      container.addSubview(fromView)
      container.addSubview(toView)
    } else {
      frontView = fromView
      backView = toView
      container.addSubview(fromView)
      container.insertSubview(toView, belowSubview: fromView)
    }
    
    setup()
  }
  func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning){
    animateTransition(transitionContext)
  }
  
  private func cancelInteractiveTransition(){
    self.transitionContext.cancelInteractiveTransition()
  }
  private func finishInteractiveTransition(){
    if !presenting{
      backViewController.viewWillAppear(true)
    }
    self.transitionContext.finishInteractiveTransition()
  }
  private func endInteractiveTransition(){
    let pan = presenting ? enterPanGesture : exitPanGesture
    let translation = pan.translationInView(pan.view!)
    var progress:CGFloat
    switch edge{
    case .Left:
      progress =  translation.x / pan.view!.frame.width
    case .Right:
      progress =  translation.x / pan.view!.frame.width * -1
    case .Bottom:
      progress =  translation.y / pan.view!.frame.height * -1
    case .Top:
      progress =  translation.y / pan.view!.frame.height
    }
    progress = presenting ? progress : -progress
    if(progress > panThreshold){
      self.finishInteractiveTransition()
    } else {
      self.cancelInteractiveTransition()
    }
  }
  
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return transitionDuration
  }
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = true
    return self
  }
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = false
    return self
  }
  
  func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    self.presenting = true
    return self.interactive ? self : nil
  }
  
  func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    self.presenting = false
    return self.interactive ? self : nil
  }
}