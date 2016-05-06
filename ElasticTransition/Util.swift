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

class DynamicItem:NSObject{
  var center: CGPoint = CGPointZero
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