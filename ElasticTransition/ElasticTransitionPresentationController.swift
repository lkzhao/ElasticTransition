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

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController:presentedViewController, presenting:presentingViewController)

        shadowView.layer.addSublayer(shadowMaskLayer)
      let tapGR = UITapGestureRecognizer(target: self, action: #selector(overlayTapped(_:)))
        overlayView.isOpaque = false
        overlayView.addGestureRecognizer(tapGR)
        overlayView.isUserInteractionEnabled = true
        shadowView.isOpaque = false
        shadowView.layer.masksToBounds = false
        overlayView.layer.zPosition = 298
        shadowView.layer.zPosition = 299
    }

    func overlayTapped(_ tapGR:UITapGestureRecognizer){
        if let delegate = presentedViewController as? ElasticMenuTransitionDelegate {
            let touchToDismiss = delegate.dismissByBackgroundTouch ?? false
            if touchToDismiss{
                transition?.startingPoint = tapGR.location(in: nil)
                presentedViewController.dismiss(animated: true, completion:nil)
            }
        }
    }

    override func presentationTransitionWillBegin() {
        containerView?.addSubview(shadowView)
        containerView?.addSubview(overlayView)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed{
            hidePresentingViewIfCovered()
        }
    }
    override func dismissalTransitionWillBegin() {
        presentingViewController.view.isHidden = false
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed {
            hidePresentingViewIfCovered()
        }
    }

    func hidePresentingViewIfCovered(){
        if let containerBounds = containerView?.bounds {
            let size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
            if size == containerBounds.size{
                presentingViewController.view.isHidden = true
            }
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        if let transition = transition, let containerBounds = containerView?.bounds {
            let size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
            switch transition.edge{
            case .left, .top:
                return CGRect(origin: CGPoint.zero, size: size)
            case .right:
                return CGRect(origin: CGPoint(x: containerBounds.width - size.width, y: 0), size: size)
            case .bottom:
                return CGRect(origin: CGPoint(x: 0, y: containerBounds.height - size.height), size: size)
            }
        }
        return presentingViewController.view.bounds
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let transition = transition {
            var contentLength:CGFloat?
            if let vc = presentedViewController as? ElasticMenuTransitionDelegate,
                let vcl = vc.contentLength{
                contentLength = vcl
            }

            switch transition.edge{
            case .left, .right:
                return CGSize(width: contentLength ?? parentSize.width, height: parentSize.height)
            case .top, .bottom:
                return CGSize(width: parentSize.width, height: contentLength ?? parentSize.height)
            }
        }
        return parentSize
    }

    override func containerViewWillLayoutSubviews() {
        if transition?.transitioning == false{
            let f = frameOfPresentedViewInContainerView
            presentedView?.frame = f
            if let containerView = containerView{
                presentingViewController.view.bounds = containerView.bounds
                presentingViewController.view.center = containerView.center
                overlayView.frame = containerView.bounds
            }
        }
    }


    func updateShadow(_ progress:CGFloat){
        if let transition = transition , transition.showShadow{
            shadowView.layer.shadowColor = transition.shadowColor.cgColor
            shadowView.layer.shadowRadius = transition.shadowRadius
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
            shadowView.layer.shadowOpacity = Float(progress)
            shadowView.layer.masksToBounds = false
        }else{
            shadowView.layer.shadowColor = nil
            shadowView.layer.shadowRadius = 0
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
            shadowView.layer.shadowOpacity = 0
            shadowView.layer.masksToBounds = true
        }
    }
    
    

    
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    
    override var adaptivePresentationStyle: UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }

}
