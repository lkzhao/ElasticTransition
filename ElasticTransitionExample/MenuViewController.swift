//
//  MenuViewController.swift
//  ElasticTransition
//
//  Created by Luke Zhao on 2015-12-09.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit

class MenuViewController: ElasticMenuViewController {

  
  override func viewDidLoad() {
    super.viewDidLoad()
    menuWidth = 300
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 0
  }
}
