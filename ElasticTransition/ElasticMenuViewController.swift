/*

The MIT License (MIT)

Copyright (c) 2015 Luke Zhao <me@lkzhao.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import UIKit

public class ElasticMenuViewController: UIViewController, ElasticMenuTransitionDelegate {
  public var contentView: UIView!{
    return tableView
  }
  var tableView: UITableView!
  
  public var edge:UIRectEdge = .Left{
    didSet{
      if leftConstraint != nil && rightConstraint != nil{
        (edge != .Left ? leftConstraint : rightConstraint).active = false
        (edge == .Left ? leftConstraint : rightConstraint).active = true
      }
    }
  }
  var leftConstraint: NSLayoutConstraint!
  var rightConstraint: NSLayoutConstraint!
  var menuWidthConstraint: NSLayoutConstraint!
  public var menuWidth:CGFloat{
    get{
      return menuWidthConstraint.constant
    }
    set{
      menuWidthConstraint.constant = newValue
      view.layoutIfNeeded()
    }
  }
  
  public var backgroundColor:UIColor?{
    didSet{
      view.backgroundColor = backgroundColor
    }
  }
  
  public override func viewDidLoad() {
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
    leftConstraint = tableView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
    rightConstraint = tableView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
    (edge == .Left ? leftConstraint : rightConstraint).active = true
    menuWidthConstraint = tableView.widthAnchor.constraintEqualToConstant(300)
    menuWidthConstraint.active = true
    
    view.layoutIfNeeded()
    
    backgroundColor = UIColor(red: 83/255, green: 91/255, blue: 97/255, alpha: 1.0)
    tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
  }
  
  public override func preferredStatusBarStyle() -> UIStatusBarStyle {
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
  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
    cell.textLabel?.text = menu[indexPath.row]
    cell.backgroundColor = UIColor.clearColor()
    cell.textLabel?.textColor = UIColor.whiteColor()
    cell.selectionStyle = .None
    return cell
  }
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menu.count
  }
}