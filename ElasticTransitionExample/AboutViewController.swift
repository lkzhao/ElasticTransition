//
//  AboutViewController.swift
//  ElasticTransitionExample
//
//  Created by Luke Zhao on 2015-12-09.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit


func getRandomColor() -> UIColor{
  let randomRed:CGFloat = CGFloat(drand48())
  let randomGreen:CGFloat = CGFloat(drand48())
  let randomBlue:CGFloat = CGFloat(drand48())
  return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
}
class AboutViewController: UIViewController {
  var transition:ElasticTransition!
  var nextViewController:AboutViewController!
  let lgr = UIScreenEdgePanGestureRecognizer()
  let rgr = UIScreenEdgePanGestureRecognizer()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = getRandomColor()
    
    // gesture recognizer
    lgr.addTarget(self, action: "handleLeftPan:")
    rgr.addTarget(self, action: "handleRightPan:")
    lgr.edges = .Left
    rgr.edges = .Right
    view.addGestureRecognizer(lgr)
    view.addGestureRecognizer(rgr)
  }
  
  func handleLeftPan(pan:UIPanGestureRecognizer){
    if pan.state == .Began{
      transition.dissmissInteractiveTransition(self, gestureRecognizer: pan, completion: nil)
    }else{
      transition.updateInteractiveTransition(gestureRecognizer: pan)
    }
  }
  
  func handleRightPan(pan:UIPanGestureRecognizer){
    if pan.state == .Began{
      nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("about") as! AboutViewController
      nextViewController.transition = transition
      nextViewController.transitioningDelegate = transition
      nextViewController.modalPresentationStyle = .Custom
      transition.edge = .Right
      transition.startInteractiveTransition(self, toViewController: nextViewController, gestureRecognizer: pan)
    }else{
      transition.updateInteractiveTransition(gestureRecognizer: pan)
    }
  }
  
  @IBAction func dismiss(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}
