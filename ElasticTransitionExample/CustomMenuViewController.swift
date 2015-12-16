//
//  CustomMenuViewController.swift
//  ElasticMenuViewController
//
//  Created by Luke Zhao on 2015-12-09.
//  Copyright © 2015 luke-z. All rights reserved.
//

import UIKit

class CustomMenuViewController: UIViewController, ElasticMenuTransitionDelegate {
  
  @IBOutlet weak var menuView: UIView!
  
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
