//
//  ElasticMenuViewController.swift
//  ElasticDropdownMenu
//
//  Created by Luke Zhao on 2015-11-30.
//  Copyright © 2015 lukezhao. All rights reserved.
//

import UIKit

class ElasticMenuViewController: UIViewController, ElasticMenuTransitionDelegate {
  var menuView: UIView!{
    return tableView
  }
  var tableView: UITableView!
  
  var edge:UIRectEdge{
    return .Left
  }
  var menuWidthConstraint: NSLayoutConstraint!
  var menuWidth:CGFloat{
    get{
      return menuWidthConstraint.constant
    }
    set{
      menuWidthConstraint.constant = newValue
      view.layoutIfNeeded()
    }
  }
  
  var backgroundColor:UIColor?{
    didSet{
      view.backgroundColor = backgroundColor
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView = UITableView(frame: CGRectZero)
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.opaque = false
    tableView.backgroundColor = UIColor.clearColor()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    
    view.addSubview(tableView)
    
    tableView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    if edge == .Left{
      tableView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
    }else{
      tableView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
    }
    menuWidthConstraint = tableView.widthAnchor.constraintEqualToConstant(300)
    menuWidthConstraint.active = true
    
    view.layoutIfNeeded()
    
    backgroundColor = UIColor(red: 83/255, green: 91/255, blue: 97/255, alpha: 1.0)
    tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  private let menu = [
    "Please subclass",
    "ElasticMenuViewController",
    "and override",
    "UITableViewDelegate &",
    "UITableViewDataSource methods",
    "to show your own content"
  ]
}

extension ElasticMenuViewController:UITableViewDelegate, UITableViewDataSource{
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
    cell.textLabel?.text = menu[indexPath.row]
    cell.backgroundColor = UIColor.clearColor()
    cell.textLabel?.textColor = UIColor.whiteColor()
    cell.selectionStyle = .None
    return cell
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menu.count
  }
}