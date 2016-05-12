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

public class EdgePanTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate{
  public var panThreshold:CGFloat = 0.2
  public var edge:Edge = .Right
  
  // private
  var transitioning = false
  var presenting = true
  var interactive = false
  var transitionContext:UIViewControllerContextTransitioning!
  var container:UIView!
  var size:CGSize{
    return container.bounds.size
  }
  var frontView:UIView{
    return frontViewController.view
  }
  var backView:UIView{
    return backViewController.view
  }
  var frontViewController: UIViewController{
    return presenting ? toViewController : fromViewController
  }
  var backViewController: UIViewController{
    return !presenting ? toViewController : fromViewController
  }
  var toView:UIView{
    return toViewController.view
  }
  var fromView:UIView{
    return fromViewController.view
  }
  var toViewController:UIViewController{
    return transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
  }
  var fromViewController:UIViewController{
    return transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
  }
  
  var currentPanGR: UIPanGestureRecognizer?
  
  var translation:CGPoint = CGPointZero
  var dragPoint:CGPoint = CGPointZero
  
  func update(){}
  
  func setup(){
    transitioning = true

    backViewController.viewWillDisappear(true)
    
    container.insertSubview(backView, atIndex: 0)
    container.addSubview(frontView)
  }

  func clean(finished: Bool){
    // bug: http://openradar.appspot.com/radar?id=5320103646199808
    UIApplication.sharedApplication().keyWindow!.addSubview(finished ? toView : fromView)

    if(!presenting && finished || presenting && !finished){
      frontView.removeFromSuperview()
      backView.layer.transform = CATransform3DIdentity

      backViewController.viewDidAppear(true)
    }

    dragPoint = CGPointZero
    currentPanGR = nil
    interactive = false
    transitioning = false
    transitionContext.completeTransition(finished)
    transitionContext = nil
    container = nil
  }

  var timeoutTimer:NSTimer?
  func resetTimeout(){
    timeoutTimer?.invalidate()
    timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(timedOut), userInfo: nil, repeats: false)
  }
  func timedOut(){
    if currentPanGR == nil || currentPanGR!.state != .Changed {
      endInteractiveTransition()
    }
  }
  func startInteractivePresent(fromViewController fromVC:UIViewController, toViewController toVC:UIViewController?, identifier:String?, pan:UIPanGestureRecognizer, presenting:Bool, completion:(() -> Void)? = nil){
    if transitioning {
      return
    }
    print("!!! Elastic Transition started presenting:\(presenting)")
    resetTimeout()
    interactive = true
    currentPanGR = pan
    translation = pan.translationInView(pan.view!)
    dragPoint = pan.locationInView(pan.view!)
    if presenting{
      if let identifier = identifier{
        fromVC.performSegueWithIdentifier(identifier, sender: self)
      }else if let toVC = toVC{
        fromVC.presentViewController(toVC, animated: true, completion: nil)
      }
    }else{
      fromVC.dismissViewControllerAnimated(true, completion: completion)
    }
  }
  
  public func updateInteractiveTransition(gestureRecognizer pan:UIPanGestureRecognizer) -> Bool?{
    if !transitioning{
      return nil
    }
    if pan.state == .Changed{
      translation = pan.translationInView(pan.view!)
      dragPoint = pan.locationInView(pan.view!)
      update()
      resetTimeout()
      return nil
    }else{
      return endInteractiveTransition()
    }
  }
  
  public func startInteractiveTransition(fromViewController:UIViewController, segueIdentifier identifier:String, gestureRecognizer pan:UIPanGestureRecognizer){
    self.startInteractivePresent(fromViewController:fromViewController, toViewController:nil, identifier:identifier, pan: pan, presenting: true)
  }
  
  public func startInteractiveTransition(fromViewController:UIViewController, toViewController:UIViewController, gestureRecognizer pan:UIPanGestureRecognizer){
    self.startInteractivePresent(fromViewController:fromViewController, toViewController:toViewController, identifier:nil, pan: pan, presenting: true)
  }
  
  public func dissmissInteractiveTransition(viewController:UIViewController, gestureRecognizer pan:UIPanGestureRecognizer, completion:(() -> Void)?){
    self.startInteractivePresent(fromViewController:viewController, toViewController:nil, identifier:nil, pan: pan, presenting: false, completion: completion)
  }
  
  
  public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    if transitioning {
        return
    }
    self.transitionContext = transitionContext
    self.container = transitionContext.containerView()
    setup()
  }
  
  public func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning){
    animateTransition(transitionContext)
  }
  
  func cancelInteractiveTransition(){
    self.transitionContext.cancelInteractiveTransition()
  }
  
  func finishInteractiveTransition(){
    self.transitionContext.finishInteractiveTransition()
  }
  
  func endInteractiveTransition() -> Bool{
    print("!!!! End Elastic Transition")
    timeoutTimer?.invalidate()
    let finished:Bool
    if let pan = currentPanGR{
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
        finished = true
      } else {
        finished = false
      }
    }else{
      finished = true
    }
    if finished{
      finishInteractiveTransition()
    }else{
      cancelInteractiveTransition()
    }
    return finished
  }
  
  
  public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }
  
  public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if transitioning{
        return nil
    }
    self.presenting = true
    return self
  }
  
  public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if transitioning{
      return nil
    }
    self.presenting = false
    return self
  }
  
  public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if transitioning{
      return nil
    }
    self.presenting = true
    return self.interactive ? self : nil
  }
  
  public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if transitioning{
      return nil
    }
    self.presenting = false
    return self.interactive ? self : nil
  }

  var presentationController:ElasticTransitionPresentationController!
  public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    presentationController = ElasticTransitionPresentationController(presentedViewController: presented, presentingViewController: presenting)
    presentationController.transition = self as? ElasticTransition
    return presentationController
  }
}
