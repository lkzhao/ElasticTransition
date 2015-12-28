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

let π:CGFloat = CGFloat(M_PI)

public enum Edge{
  case Top, Bottom, Left, Right
  public func opposite() -> Edge{
    switch self {
    case .Left:
      return .Right
    case .Right:
      return .Left
    case .Bottom:
      return .Top
    case .Top:
      return .Bottom
    }
  }
  public func toUIRectEdge() -> UIRectEdge{
    switch self {
    case .Left:
      return .Left
    case .Right:
      return .Right
    case .Bottom:
      return .Bottom
    case .Top:
      return .Top
    }
  }
}

extension CGPoint{
  func translate(dx:CGFloat, dy:CGFloat) -> CGPoint{
    return CGPointMake(self.x+dx, self.y+dy)
  }
  
  func transform(t:CGAffineTransform) -> CGPoint{
    return CGPointApplyAffineTransform(self, t)
  }
  
  func distance(b:CGPoint)->CGFloat{
    return sqrt(pow(self.x-b.x,2)+pow(self.y-b.y,2));
  }
}

class DynamicItem:NSObject, UIDynamicItem{
  var center: CGPoint = CGPointZero
  var bounds: CGRect = CGRectMake(0, 0, 1, 1)
  var transform: CGAffineTransform = CGAffineTransformIdentity
  init(center:CGPoint) {
    self.center = center
    super.init()
  }
}

class CustomSnapBehavior:UIDynamicBehavior {
  var ab1:UIAttachmentBehavior!
  var ab2:UIAttachmentBehavior!
  var ab3:UIAttachmentBehavior!
  var ab4:UIAttachmentBehavior!
  
  var item:UIDynamicItem
  
  var frequency:CGFloat = 1{
    didSet{
      ab1.frequency = frequency
      ab2.frequency = frequency
      ab3.frequency = frequency
      ab4.frequency = frequency
    }
  }
  var damping:CGFloat = 0{
    didSet{
      ab1.damping = damping
      ab2.damping = damping
      ab3.damping = damping
      ab4.damping = damping
    }
  }
  var point:CGPoint{
    didSet{
      updatePoints()
    }
  }
  func updatePoints(){
    ab1.anchorPoint = point.translate(50, dy: 0)
    ab2.anchorPoint = point.translate(-50, dy: 0)
    ab3.anchorPoint = point.translate(0, dy: 50)
    ab4.anchorPoint = point.translate(0, dy: -50)
  }
  
  init(item:UIDynamicItem, point:CGPoint, useSnap:Bool = false) {
    self.item = item
    self.point = point
    super.init()
    
    ab1 = UIAttachmentBehavior(item: item, attachedToAnchor: point)
    addChildBehavior(ab1)
    ab2 = UIAttachmentBehavior(item: item, attachedToAnchor: point)
    addChildBehavior(ab2)
    ab3 = UIAttachmentBehavior(item: item, attachedToAnchor: point)
    addChildBehavior(ab3)
    ab4 = UIAttachmentBehavior(item: item, attachedToAnchor: point)
    addChildBehavior(ab4)
    ab1.length = 50
    ab2.length = 50
    ab3.length = 50
    ab4.length = 50
    updatePoints()
  }
}
