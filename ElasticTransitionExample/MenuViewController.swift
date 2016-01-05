//
//  MenuViewController.swift
//  ElasticTransitionExample
//
//  Created by Luke Zhao on 2015-12-09.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, ElasticMenuTransitionDelegate {

  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var contentView:UIView!
  
  @IBOutlet weak var codeView2: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tm = transitioningDelegate as! ElasticTransition
    textView.text = "transition.edge = .\(tm.edge)\n" +
      "transition.transformType = .\(tm.transformType)\n" +
      "transition.sticky = \(tm.sticky)\n" +
      "transition.showShadow = \(tm.showShadow)"
    
    codeView2.text = "let vc = segue.destinationViewController\n" +
      "vc.transitioningDelegate = transition\n" +
      "vc.modalPresentationStyle = .Custom\n"
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}
