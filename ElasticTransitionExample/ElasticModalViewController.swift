//
//  ElasticModalViewController.swift
//  Footprint
//
//  Created by Luke on 3/27/16.
//  Copyright © 2016 Luke Zhao. All rights reserved.
//

import UIKit

public class ElasticModalViewController: UIViewController, ElasticMenuTransitionDelegate {
  
  public var dragDownTransformType:ElasticTransitionBackgroundTransform = .subtle
  public var dragRightTransformType:ElasticTransitionBackgroundTransform = .translatePull
  
  lazy var modalTransition:ElasticTransition = {
    let transition = ElasticTransition()
    transition.edge = .bottom
    transition.sticky = true
    transition.panThreshold = 0.2
    transition.interactiveRadiusFactor = 0.4
    transition.showShadow = true
    return transition
  }()
  
  public var dismissByForegroundDrag:Bool {
    return modalTransition.edge == .bottom
  }

  let leftDissmissPanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
  

  public init(){
    super.init(nibName: nil, bundle: nil)
    transitioningDelegate = modalTransition
    modalPresentationStyle = .custom
  }

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    transitioningDelegate = modalTransition
    modalPresentationStyle = .custom
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    transitioningDelegate = modalTransition
    modalPresentationStyle = .custom
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    leftDissmissPanGestureRecognizer.addTarget(self, action: #selector(handleLeftPan))
    leftDissmissPanGestureRecognizer.edges = .left
    view.addGestureRecognizer(leftDissmissPanGestureRecognizer)
    modalTransition.foregroundExitPanGestureRecognizer.require(toFail: leftDissmissPanGestureRecognizer)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    modalTransition.edge = .bottom
    modalTransition.transformType = dragDownTransformType
  }
  
  func dismissFromTop(_ sender:UIView?){
    modalTransition.edge = .bottom
    modalTransition.transformType = dragDownTransformType
    modalTransition.startingPoint = sender?.center
    dismiss(animated: true, completion: nil)
  }
  
  func dismissFromLeft(_ sender:UIView?){
    modalTransition.transformType = dragRightTransformType
    modalTransition.edge = .right
    modalTransition.startingPoint = sender?.center
    dismiss(animated: true, completion: nil)
  }
  
  public func handleLeftPan(_ pan:UIPanGestureRecognizer){
    if pan.state == .began{
      modalTransition.transformType = dragRightTransformType
      modalTransition.edge = .right
      modalTransition.dissmissInteractiveTransition(self, gestureRecognizer: pan){}
    } else {
      _ = modalTransition.updateInteractiveTransition(gestureRecognizer: pan)
    }
  }
  
}
