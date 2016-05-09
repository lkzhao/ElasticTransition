//
//  ModalExampleViewController.swift
//  ElasticTransitionExample
//
//  Created by YiLun Zhao on 2016-01-02.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class ModalExampleViewController: ElasticModalViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = getRandomColor()
  }

  @IBAction func showMore(sender: AnyObject) {
    let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("modalExample") as! ModalExampleViewController
    presentViewController(nextViewController, animated: true, completion: nil)
  }

  @IBAction func showFromRight(sender: AnyObject) {
    let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("modalExample") as! ModalExampleViewController
    nextViewController.modalTransition.edge = .Right
    presentViewController(nextViewController, animated: true, completion: nil)
  }
}
