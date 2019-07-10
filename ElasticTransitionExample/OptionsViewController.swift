//
//  OptionsViewController.swift
//  ElasticTransitionExample
//
//  Created by Luke Zhao on 2015-12-08.
//  Copyright © 2015 lkzhao. All rights reserved.
//

import UIKit

enum LeftMenuType{
  case `switch`(name:String, on:Bool, onChange:(_ on:Bool)->Void)
  case slider(name:String, value:Float, onChange:(_ value:Float)->Void)
  case segment(name:String, values:[Any], selected:Int, onChange:(_ value:Any)->Void)
}
class SwitchCell:UITableViewCell{
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var control: UISwitch!
  var onChange:((_ on:Bool)->Void)?
  @IBAction func switchChanged(_ sender: UISwitch) {
    onChange?(sender.isOn)
  }
}
class SliderCell:UITableViewCell{
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var slider: UISlider!
  
  var onChange:((_ value:Float)->Void)?
  @IBAction func sliderChanged(_ sender: UISlider) {
    onChange?(sender.value)
  }
}
class SegmentCell:UITableViewCell{
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var segment: UISegmentedControl!
  
  var values:[Any] = []
  var onChange:((_ value:Any)->Void)?

  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    onChange?(values[sender.selectedSegmentIndex])
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
    let va:[Any] = [ElasticTransitionBackgroundTransform.subtle,ElasticTransitionBackgroundTransform.rotate,ElasticTransitionBackgroundTransform.translateMid]
    menu = []
    menu.append(.switch(name: "Sticky", on:tm.sticky, onChange: {on in
      tm.sticky = on
    }))
    menu.append(.switch(name: "Shadow", on:tm.showShadow, onChange: {on in
      tm.showShadow = on
    }))
    menu.append(LeftMenuType.segment(name: "Transform Type",values:va,selected:tm.transformType.rawValue, onChange: {value in
      tm.transformType = value as! ElasticTransitionBackgroundTransform
    }))
    menu.append(.slider(name: "Damping", value:Float(tm.damping), onChange: {value in
      tm.damping = CGFloat(value)
    }))
    menu.append(.slider(name: "Stiffness", value:Float(tm.stiffness), onChange: {value in
      tm.stiffness = CGFloat(value)
    }))
    menu.append(.slider(name: "Radius Factor", value:Float(tm.radiusFactor)/0.5, onChange: {value in
      tm.radiusFactor = CGFloat(value) * CGFloat(0.5)
    }))
    menu.append(.slider(name: "Pan Theashold", value:Float(tm.panThreshold), onChange: {value in
      tm.panThreshold = CGFloat(value)
    }))
    
    for i in 0..<menu.count{
      contentLength += self.tableView(self.tableView, heightForRowAt: IndexPath(row:i, section:0))
    }
    tableView.reloadData()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle { return UIStatusBarStyle.lightContent }
}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:UITableViewCell
    switch menu[(indexPath as NSIndexPath).item]{
    case .switch(let name, let on, let onChange):
      let switchCell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as! SwitchCell
      switchCell.onChange = onChange
      switchCell.nameLabel.text = name
      switchCell.control.isOn = on
      cell = switchCell
    case .segment(let name, let values, let selected, let onChange):
      let segmentCell  = tableView.dequeueReusableCell(withIdentifier: "segment", for: indexPath) as! SegmentCell
      segmentCell.onChange = onChange
      segmentCell.nameLabel.text = name
      segmentCell.segment.removeAllSegments()
      segmentCell.values = values
      for v in values.reversed(){
        segmentCell.segment.insertSegment(withTitle: "\(v)", at: 0, animated: false)
      }
      segmentCell.segment.selectedSegmentIndex = selected
      cell = segmentCell
    case .slider(let name, let value, let onChange):
      let sliderCell  = tableView.dequeueReusableCell(withIdentifier: "slider", for: indexPath) as! SliderCell
      sliderCell.onChange = onChange
      sliderCell.nameLabel.text = name
      sliderCell.slider.maximumValue = 1.0
      sliderCell.slider.minimumValue = 0
      sliderCell.slider.value = value
      cell = sliderCell
    }
    return cell
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menu.count
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch menu[(indexPath as NSIndexPath).item]{
    case .switch:
      return 54
    case .slider:
      return 62
    default:
      return 72
    }
  }
}
