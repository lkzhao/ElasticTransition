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

public class EdgePanTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate{
    public var transitionDuration = 0.7
    public var panThreshold:CGFloat = 0.2
    public var autoSetupPresentGestureRecognizer = true
    public var autoSetupDismissGestureRecognizer = true
    public var segueIdentifier = "menu"
    public var edge:Edge = .Left{
        didSet{
            enterPanGesture.edges = edge.toUIRectEdge()
        }
    }
    public var backViewController: UIViewController! {
        didSet {
            backViewController.transitioningDelegate = self
            backViewController.modalPresentationStyle = .OverCurrentContext;
            if autoSetupPresentGestureRecognizer {
                backViewController.view.addGestureRecognizer(self.enterPanGesture)
            }
        }
    }
    
    public var frontViewController: UIViewController! {
        didSet {
            frontViewController.transitioningDelegate = self
            frontViewController.modalPresentationStyle = .OverCurrentContext;
            if autoSetupDismissGestureRecognizer {
                frontViewController.view.addGestureRecognizer(self.exitPanGesture)
            }
        }
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !transitioning
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isKindOfClass(UISlider.self) {
            return false
        }
        return true;
    }
    
    public override init(){
        super.init()
        enterPanGesture.delegate = self
        enterPanGesture.addTarget(self, action:"handleOnstagePan:")
        enterPanGesture.edges = edge.toUIRectEdge()
        exitPanGesture.delegate = self
        exitPanGesture.addTarget(self, action:"handleOffstagePan:")
    }
    
    // private
    var transitioning = false
    var presenting = true
    var interactive = false
    
    var container:UIView!
    var size:CGSize{
        return container.bounds.size
    }
    
    var frontView:UIView!
    var backView:UIView!
    var toView:UIView!
    var fromView:UIView!
    var toViewController:UIViewController!
    var fromViewController:UIViewController!
    var transitionContext:UIViewControllerContextTransitioning!
    
    var enterPanGesture: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
    var exitPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    var currentPanGR: UIPanGestureRecognizer?
    
    var translation:CGPoint = CGPointZero
    var dragPoint:CGPoint = CGPointZero{
        didSet{
            update()
        }
    }
    
    func update(){}
    
    func setup(){
        transitioning = true
    }
    
    func clean(finished: Bool){
        // bug: http://openradar.appspot.com/radar?id=5320103646199808
        UIApplication.sharedApplication().keyWindow!.addSubview(finished ? toView : fromView)
        
        if presenting && !interactive{
            backViewController.viewWillAppear(true)
        }
        if(!presenting && finished || presenting && !finished){
            frontView.removeFromSuperview()
            backView.layer.transform = CATransform3DIdentity
            backView.frame = container.bounds
            backViewController.viewDidAppear(true)
        }
        
        currentPanGR = nil
        interactive = false
        transitioning = false
        transitionContext.completeTransition(finished)
    }
    
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        switch (pan.state) {
        case UIGestureRecognizerState.Began:
            startInteractiveSegue(segueIdentifier, pan: pan)
        default:
            updateInteractiveSegue(pan)
        }
    }
    
    func handleOffstagePan(pan: UIPanGestureRecognizer){
        switch (pan.state) {
        case UIGestureRecognizerState.Began:
            dissmissInteractiveSegue(segueIdentifier, pan: pan, completion: nil)
        default:
            updateInteractiveSegue(pan)
        }
    }
    
    func startInteractiveSegue(identifier:String, pan:UIPanGestureRecognizer, presenting:Bool, completion:(() -> Void)? = nil){
        interactive = true
        currentPanGR = pan
        backViewController.transitioningDelegate = self
        if presenting{
            backViewController.performSegueWithIdentifier(identifier, sender: self)
        }else{
            frontViewController.dismissViewControllerAnimated(true, completion: completion)
        }
        frontViewController.transitioningDelegate = self
        translation = pan.translationInView(container)
        dragPoint = pan.locationInView(container)
    }
    
    public func updateInteractiveSegue(pan:UIPanGestureRecognizer){
        if !transitioning{
            return
        }
        if pan.state == .Changed{
            translation = pan.translationInView(container)
            dragPoint = pan.locationInView(container)
        }else{
            endInteractiveTransition()
        }
    }
    
    public func startInteractiveSegue(identifier:String, pan:UIPanGestureRecognizer){
        self.startInteractiveSegue(identifier, pan: pan, presenting: true)
    }
    
    public func dissmissInteractiveSegue(identifier:String, pan:UIPanGestureRecognizer, completion:(() -> Void)?){
        self.startInteractiveSegue(identifier, pan: pan, presenting: false, completion: completion)
    }
    
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
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
    
    public func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning){
        animateTransition(transitionContext)
    }
    
    func cancelInteractiveTransition(){
        self.transitionContext.cancelInteractiveTransition()
    }
    
    func finishInteractiveTransition(){
        if !presenting{
            backViewController.viewWillAppear(true)
        }
        self.transitionContext.finishInteractiveTransition()
    }
    
    func endInteractiveTransition(){
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
                self.finishInteractiveTransition()
            } else {
                self.cancelInteractiveTransition()
            }
        }else{
            self.finishInteractiveTransition()
        }
    }
    
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transitionDuration
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.presenting = true
        return self.interactive ? self : nil
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.presenting = false
        return self.interactive ? self : nil
    }
}
