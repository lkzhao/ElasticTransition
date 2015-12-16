//
//  RightMenuViewController.swift
//  ElasticTransition
//
//  Created by Luke Zhao on 2015-12-09.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit

class RightMenuViewController: ElasticMenuViewController {
  override var edge:UIRectEdge{
    return .Right
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    menuWidth = 200
  }
}
