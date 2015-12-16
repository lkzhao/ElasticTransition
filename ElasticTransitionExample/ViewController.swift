//
//  ViewController.swift
//  ElasticMenuViewController
//
//  Created by Luke Zhao on 2015-12-08.
//  Copyright © 2015 luke-z. All rights reserved.
//

import UIKit

class Menu {
  var name:String
  var description:String
  var identifier:String
  var edge:Edge
  init(_ name:String, _ description:String, _ identifier:String, _ edge:Edge = .Left){
    self.name = name
    self.description = description
    self.identifier = identifier
    self.edge = edge
  }
}


class ViewController: UITableViewController {
  
  var transitionManager = ElasticTransitionManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    menus = [
      Menu("Left TableView Menu", "options", "menu"),
      Menu("Right TableView Menu", "basic menu that subclass ElasticMenuViewController", "rmenu", .Right),
      Menu("Custom Menu", "build in storyboard", "cmenu", .Bottom),
      Menu("Right Detail", "with low radiusFactor", "detail", .Right),
    ]
    transitionManager.segueIdentifier = "menu"
    transitionManager.backViewController = self
    transitionManager.sticky = false
    transitionManager.panThreshold = 0.3
    transitionManager.fancyTransform = false
    self.clearsSelectionOnViewWillAppear = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPath = tableView.indexPathForSelectedRow{
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    segue.destinationViewController.transitioningDelegate = transitionManager
    transitionManager.frontViewController = segue.destinationViewController
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
  var menus:[Menu]!

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath)
    cell.textLabel?.text =  menus[indexPath.item].name
    cell.detailTextLabel?.text =  menus[indexPath.item].description
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    transitionManager.origin = tableView.cellForRowAtIndexPath(indexPath)?.center
    transitionManager.segueIdentifier = menus[indexPath.item].identifier
    transitionManager.edge = menus[indexPath.item].edge
    performSegueWithIdentifier(menus[indexPath.item].identifier, sender: self)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menus.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 150
  }
}

