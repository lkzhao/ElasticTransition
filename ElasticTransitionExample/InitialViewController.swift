//
//  InitialViewController.swift
//  ElasticTransitionExample
//
//  Created by Luke Zhao on 2015-12-16.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
  
  
  var transition = ElasticTransition()
  let lgr = UIScreenEdgePanGestureRecognizer()
  let rgr = UIScreenEdgePanGestureRecognizer()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // this tells the transition to not automatically setup the present gestureRecognizer
    transition.autoSetupPresentGestureRecognizer = false
    transition.backViewController = self
    
    // customization
    transition.sticky = true
    transition.panThreshold = 0.3
    transition.fancyTransform = true
    
    // gesture recognizer
    lgr.addTarget(self, action: "handlePan:")
    rgr.addTarget(self, action: "handlePan:")
    lgr.edges = .Left
    rgr.edges = .Right
    self.view.addGestureRecognizer(lgr)
    self.view.addGestureRecognizer(rgr)
  }
  
  
  
  func handlePan(pan:UIPanGestureRecognizer){
    if pan.state == .Began{
      transition.edge = pan == lgr ? .Left:.Right
      transition.startInteractiveSegue("menu", pan: pan)
    }else{
      transition.updateInteractiveSegue(pan)
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    transition.edge = .Bottom
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "menu"{
      let vc = segue.destinationViewController as! MenuViewController
      vc.edge = transition.edge.toUIRectEdge()
    }
    transition.frontViewController = segue.destinationViewController
  }
  
}
