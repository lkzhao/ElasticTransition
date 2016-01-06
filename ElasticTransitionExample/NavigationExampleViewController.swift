//
//  NavigationExampleViewController.swift
//  ElasticTransitionExample
//
//  Created by YiLun Zhao on 2016-01-02.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class NavigationExampleViewController: UIViewController {
  

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = getRandomColor()
  }
  @IBAction func dismiss(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func showMore(sender: AnyObject) {
    let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("navigationExample") as! NavigationExampleViewController
    navigationController?.pushViewController(nextViewController, animated: true)
  }
}
