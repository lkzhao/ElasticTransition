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
    
    // customization
    transition.sticky = true
    transition.showShadow = true
    transition.panThreshold = 0.3
    transition.transformType = .translateMid
    
//    transition.overlayColor = UIColor(white: 0, alpha: 0.5)
//    transition.shadowColor = UIColor(white: 0, alpha: 0.5)
    
    // gesture recognizer
    lgr.addTarget(self, action: #selector(InitialViewController.handlePan(_:)))
    rgr.addTarget(self, action: #selector(InitialViewController.handleRightPan(_:)))
    lgr.edges = .left
    rgr.edges = .right
    view.addGestureRecognizer(lgr)
    view.addGestureRecognizer(rgr)
  }
  
  @objc func handlePan(_ pan:UIPanGestureRecognizer){
    if pan.state == .began{
      transition.edge = .left
      transition.startInteractiveTransition(self, segueIdentifier: "menu", gestureRecognizer: pan)
      transition.startInteractiveTransition(self, segueIdentifier: "menu", gestureRecognizer: pan)
    }else{
      _ = transition.updateInteractiveTransition(gestureRecognizer: pan)
    }
  }
  
  @objc func handleRightPan(_ pan:UIPanGestureRecognizer){
    if pan.state == .began{
      transition.edge = .right
      transition.startInteractiveTransition(self, segueIdentifier: "about", gestureRecognizer: pan)
    }else{
      _ = transition.updateInteractiveTransition(gestureRecognizer: pan)
    }
  }
  
  @IBAction func codeBtnTouched(_ sender: AnyObject) {
    transition.edge = .left
    transition.startingPoint = sender.center
    performSegue(withIdentifier: "menu", sender: self)
  }
  
  @IBAction func optionBtnTouched(_ sender: AnyObject) {
    transition.edge = .bottom
    transition.startingPoint = sender.center
    performSegue(withIdentifier: "option", sender: self)
  }

  @IBAction func aboutBtnTouched(_ sender: AnyObject) {
    transition.edge = .right
    transition.startingPoint = sender.center
    performSegue(withIdentifier: "about", sender: self)
  }
  
  @IBAction func modalBtnTouched(_ sender: AnyObject) {
    let modalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "modalExample") as! ModalExampleViewController
    present(modalViewController, animated: true, completion: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination
    vc.transitioningDelegate = transition
    vc.modalPresentationStyle = .custom
  }
  
}
