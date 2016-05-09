//
//  ElasticModalViewController.swift
//  Footprint
//
//  Created by Luke on 3/27/16.
//  Copyright © 2016 Luke Zhao. All rights reserved.
//

import UIKit

public class ElasticModalViewController: UIViewController, ElasticMenuTransitionDelegate {
  
  public var dragDownTransformType:ElasticTransitionBackgroundTransform = .Subtle
  public var dragRightTransformType:ElasticTransitionBackgroundTransform = .TranslatePull
  
  lazy var modalTransition:ElasticTransition = {
    let transition = ElasticTransition()
    transition.edge = .Bottom
    transition.sticky = true
    transition.panThreshold = 0.2
    transition.interactiveRadiusFactor = 0.4
    transition.showShadow = true
    return transition
  }()
  
  public var dismissByForegroundDrag:Bool {
    return modalTransition.edge == .Bottom
  }

  let leftDissmissPanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
  

  public init(){
    super.init(nibName: nil, bundle: nil)
    transitioningDelegate = modalTransition
    modalPresentationStyle = .Custom
  }

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    transitioningDelegate = modalTransition
    modalPresentationStyle = .Custom
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    transitioningDelegate = modalTransition
    modalPresentationStyle = .Custom
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    leftDissmissPanGestureRecognizer.addTarget(self, action: #selector(handleLeftPan))
    leftDissmissPanGestureRecognizer.edges = .Left
    view.addGestureRecognizer(leftDissmissPanGestureRecognizer)
    modalTransition.foregroundExitPanGestureRecognizer.requireGestureRecognizerToFail(leftDissmissPanGestureRecognizer)
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    modalTransition.edge = .Bottom
    modalTransition.transformType = dragDownTransformType
  }
  
  func dismissFromTop(sender:UIView?){
    modalTransition.edge = .Bottom
    modalTransition.transformType = dragDownTransformType
    modalTransition.startingPoint = sender?.center
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func dismissFromLeft(sender:UIView?){
    modalTransition.transformType = dragRightTransformType
    modalTransition.edge = .Right
    modalTransition.startingPoint = sender?.center
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  public func handleLeftPan(pan:UIPanGestureRecognizer){
    if pan.state == .Began{
      modalTransition.transformType = dragRightTransformType
      modalTransition.edge = .Right
      modalTransition.dissmissInteractiveTransition(self, gestureRecognizer: pan){}
    } else {
      modalTransition.updateInteractiveTransition(gestureRecognizer: pan)
    }
  }
  
}
