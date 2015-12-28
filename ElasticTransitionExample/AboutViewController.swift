//
//  AboutViewController.swift
//  ElasticTransitionExample
//
//  Created by Luke Zhao on 2015-12-09.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, ElasticMenuTransitionDelegate {
  
  @IBOutlet weak var contentView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func dismiss(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}
