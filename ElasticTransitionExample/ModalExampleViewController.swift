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

  @IBAction func showMore(_ sender: AnyObject) {
    let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "modalExample") as! ModalExampleViewController
    present(nextViewController, animated: true, completion: nil)
  }

  @IBAction func showFromRight(_ sender: AnyObject) {
    let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "modalExample") as! ModalExampleViewController
    nextViewController.modalTransition.edge = .right
    present(nextViewController, animated: true, completion: nil)
  }
}
