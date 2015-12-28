//
//  OptionsViewController.swift
//  ElasticTransitionExample
//
//  Created by Luke Zhao on 2015-12-08.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit

enum LeftMenuType{
  case Switch(name:String, on:Bool, onChange:(on:Bool)->Void)
  case Slider(name:String, value:Float, onChange:(value:Float)->Void)
}
class SwitchCell:UITableViewCell{
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var control: UISwitch!
  var onChange:((on:Bool)->Void)?
  @IBAction func switchChanged(sender: UISwitch) {
    onChange?(on: sender.on)
  }
}
class SliderCell:UITableViewCell{
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var slider: UISlider!
  
  var onChange:((value:Float)->Void)?
  @IBAction func sliderChanged(sender: UISlider) {
    onChange?(value: sender.value)
  }
}
class OptionsViewController: UIViewController, ElasticMenuTransitionDelegate {
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
  
  var menu:[LeftMenuType] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tm = self.transitioningDelegate as! ElasticTransition
    menu = [
      .Switch(name: "Sticky", on:tm.sticky, onChange: {on in
        tm.sticky = on
      }),
      .Switch(name: "Fancy Transform",on:tm.fancyTransform, onChange: {on in
        tm.fancyTransform = on
      }),
      .Slider(name: "Damping", value:Float(tm.damping), onChange: {value in
        tm.damping = CGFloat(value)
      }),
      .Slider(name: "Radius Factor", value:Float(tm.radiusFactor)/0.5, onChange: {value in
        tm.radiusFactor = CGFloat(value) * CGFloat(0.5)
      }),
      .Slider(name: "Pan Theashold", value:Float(tm.panThreshold), onChange: {value in
        tm.panThreshold = CGFloat(value)
      }),
    ]
    
    var height:CGFloat = 0
    for i in 0..<menu.count{
      height += self.tableView(self.tableView, heightForRowAtIndexPath: NSIndexPath(forRow:i, inSection:0))
    }
    contentViewHeight.constant = height
    tableView.reloadData()
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource{
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell:UITableViewCell
    switch menu[indexPath.item]{
    case .Switch(let name, let on, let onChange):
      let switchCell = tableView.dequeueReusableCellWithIdentifier("switch", forIndexPath: indexPath) as! SwitchCell
      switchCell.onChange = onChange
      switchCell.nameLabel.text = name
      switchCell.control.on = on
      cell = switchCell
    case .Slider(let name, let value, let onChange):
      let sliderCell  = tableView.dequeueReusableCellWithIdentifier("slider", forIndexPath: indexPath) as! SliderCell
      sliderCell.onChange = onChange
      sliderCell.nameLabel.text = name
      sliderCell.slider.maximumValue = 1.0
      sliderCell.slider.minimumValue = 0
      sliderCell.slider.value = value
      cell = sliderCell
    }
    return cell
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menu.count
  }
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    switch menu[indexPath.item]{
    case .Switch:
      return 54
    case .Slider:
      return 84
    }
  }
}