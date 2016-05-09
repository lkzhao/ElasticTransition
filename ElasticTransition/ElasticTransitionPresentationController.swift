//
//  ElasticTransitionPresentationController.swift
//  ElasticTransitionExample
//
//  Created by Luke on 4/26/16.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class ElasticTransitionPresentationController:UIPresentationController,UIAdaptivePresentationControllerDelegate {
    weak var transition:ElasticTransition?

    var overlayView = UIView()
    var shadowView = UIView()
    var shadowMaskLayer = ElasticShapeLayer()

    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController:presentedViewController, presentingViewController:presentingViewController)

        shadowView.layer.addSublayer(shadowMaskLayer)
      let tapGR = UITapGestureRecognizer(target: self, action: #selector(overlayTapped(_:)))
        overlayView.opaque = false
        overlayView.addGestureRecognizer(tapGR)
        overlayView.userInteractionEnabled = true
        shadowView.opaque = false
        shadowView.layer.masksToBounds = false
        overlayView.layer.zPosition = 298
        shadowView.layer.zPosition = 299
    }

    func overlayTapped(tapGR:UITapGestureRecognizer){
        if let delegate = presentedViewController as? ElasticMenuTransitionDelegate {
            let touchToDismiss = delegate.dismissByBackgroundTouch ?? false
            if touchToDismiss{
                transition?.startingPoint = tapGR.locationInView(nil)
                presentedViewController.dismissViewControllerAnimated(true, completion:nil)
            }
        }
    }

    override func presentationTransitionWillBegin() {
        containerView?.addSubview(shadowView)
        containerView?.addSubview(overlayView)
    }

    override func presentationTransitionDidEnd(completed: Bool) {
        if completed{
            hidePresentingViewIfCovered()
        }
    }
    override func dismissalTransitionWillBegin() {
        presentingViewController.view.hidden = false
    }
    override func dismissalTransitionDidEnd(completed: Bool) {
        if !completed {
            hidePresentingViewIfCovered()
        }
    }

    func hidePresentingViewIfCovered(){
        if let containerBounds = containerView?.bounds {
            let size = sizeForChildContentContainer(presentedViewController, withParentContainerSize: containerBounds.size)
            if size == containerBounds.size{
                presentingViewController.view.hidden = true
            }
        }
    }
    override func frameOfPresentedViewInContainerView() -> CGRect {
        if let transition = transition, containerBounds = containerView?.bounds {
            let size = sizeForChildContentContainer(presentedViewController, withParentContainerSize: containerBounds.size)
            switch transition.edge{
            case .Left, .Top:
                return CGRect(origin: CGPointZero, size: size)
            case .Right:
                return CGRect(origin: CGPointMake(containerBounds.width - size.width, 0), size: size)
            case .Bottom:
                return CGRect(origin: CGPointMake(0, containerBounds.height - size.height), size: size)
            }
        }
        return presentingViewController.view.bounds
    }

    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let transition = transition {
            var contentLength:CGFloat?
            if let vc = presentedViewController as? ElasticMenuTransitionDelegate,
                let vcl = vc.contentLength{
                contentLength = vcl
            }

            switch transition.edge{
            case .Left, .Right:
                return CGSizeMake(contentLength ?? parentSize.width, parentSize.height)
            case .Top, .Bottom:
                return CGSizeMake(parentSize.width, contentLength ?? parentSize.height)
            }
        }
        return parentSize
    }

    override func containerViewWillLayoutSubviews() {
        if transition?.transitioning == false{
            let f = frameOfPresentedViewInContainerView()
            presentedView()?.frame = f
            if let containerView = containerView{
                presentingViewController.view.bounds = containerView.bounds
                presentingViewController.view.center = containerView.center
                overlayView.frame = containerView.bounds
            }
        }
    }


    func updateShadow(progress:CGFloat){
        if let transition = transition where transition.showShadow{
            shadowView.layer.shadowColor = transition.shadowColor.CGColor
            shadowView.layer.shadowRadius = transition.shadowRadius
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

    override func shouldPresentInFullscreen() -> Bool {
        return true
    }

    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }

}