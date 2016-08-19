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
import MotionAnimation

let π:CGFloat = CGFloat(M_PI)

@objc public enum Edge:Int{
  case top, bottom, left, right
  public func opposite() -> Edge{
    switch self {
    case .left:
      return .right
    case .right:
      return .left
    case .bottom:
      return .top
    case .top:
      return .bottom
    }
  }
  public func toUIRectEdge() -> UIRectEdge{
    switch self {
    case .left:
      return .left
    case .right:
      return .right
    case .bottom:
      return .bottom
    case .top:
      return .top
    }
  }
}

extension CGPoint{
  func translate(_ dx:CGFloat, dy:CGFloat) -> CGPoint{
    return CGPoint(x: self.x+dx, y: self.y+dy)
  }

  func transform(_ t:CGAffineTransform) -> CGPoint{
    return self.applying(t)
  }

  func distance(_ b:CGPoint)->CGFloat{
    return sqrt(pow(self.x-b.x,2)+pow(self.y-b.y,2));
  }
}

class DynamicItem:NSObject{
  var center: CGPoint = CGPoint.zero
  init(center:CGPoint) {
    self.center = center
    super.init()
    self.m_defineCustomProperty("center", getter: { [weak self] values in
            self?.center.toCGFloatValues(&values)
        }, setter: { [weak self] values in
            self?.center = CGPoint.fromCGFloatValues(values)
        })
  }
}
