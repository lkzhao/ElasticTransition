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
  case Segment(name:String, values:[Any], selected:Int, onChange:(value:Any)->Void)
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
class SegmentCell:UITableViewCell{
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var segment: UISegmentedControl!
  
  var values:[Any] = []
  var onChange:((value:Any)->Void)?

  @IBAction func segmentChanged(sender: UISegmentedControl) {
    onChange?(value: values[sender.selectedSegmentIndex])
  }
}
class OptionsViewController: UIViewController, ElasticMenuTransitionDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  var contentLength:CGFloat = 0
  var dismissByBackgroundTouch = true
  var dismissByBackgroundDrag = true
  var dismissByForegroundDrag = true
  
  var menu:[LeftMenuType] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tm = self.transitioningDelegate as! ElasticTransition
    let va:[Any] = [ElasticTransitionBackgroundTransform.None,ElasticTransitionBackgroundTransform.Rotate,ElasticTransitionBackgroundTransform.TranslateMid]
    menu = []
    menu.append(.Switch(name: "Sticky", on:tm.sticky, onChange: {on in
      tm.sticky = on
    }))
    menu.append(.Switch(name: "Shadow", on:tm.showShadow, onChange: {on in
      tm.showShadow = on
    }))
    menu.append(LeftMenuType.Segment(name: "Transform Type",values:va,selected:tm.transformType.rawValue, onChange: {value in
      tm.transformType = value as! ElasticTransitionBackgroundTransform
    }))
    menu.append(.Slider(name: "Damping", value:Float(tm.damping), onChange: {value in
      tm.damping = CGFloat(value)
    }))
    menu.append(.Slider(name: "Radius Factor", value:Float(tm.radiusFactor)/0.5, onChange: {value in
      tm.radiusFactor = CGFloat(value) * CGFloat(0.5)
    }))
    menu.append(.Slider(name: "Pan Theashold", value:Float(tm.panThreshold), onChange: {value in
      tm.panThreshold = CGFloat(value)
    }))
    
    for i in 0..<menu.count{
      contentLength += self.tableView(self.tableView, heightForRowAtIndexPath: NSIndexPath(forRow:i, inSection:0))
    }
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
    case .Segment(let name, let values, let selected, let onChange):
      let segmentCell  = tableView.dequeueReusableCellWithIdentifier("segment", forIndexPath: indexPath) as! SegmentCell
      segmentCell.onChange = onChange
      segmentCell.nameLabel.text = name
      segmentCell.segment.removeAllSegments()
      segmentCell.values = values
      for v in values.reverse(){
        segmentCell.segment.insertSegmentWithTitle("\(v)", atIndex: 0, animated: false)
      }
      segmentCell.segment.selectedSegmentIndex = selected
      cell = segmentCell
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
      return 62
    default:
      return 72
    }
  }
}