//
//  ValueAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-18.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public typealias CGFloatValueBlock = ((inout [CGFloat]) -> Void)

public class ValueAnimation:MotionAnimation {
  private var getter:CGFloatValueBlock
  private var setter:CGFloatValueBlock
  public var velocity:[CGFloat]
  public var values:[CGFloat]
  public var target:[CGFloat]{
    didSet{
      getter(&values)
      if target != values{
        play()
      }
    }
  }

  public init(count:Int, getter:CGFloatValueBlock, setter:CGFloatValueBlock, target:[CGFloat]? = nil, velocity:[CGFloat]? = nil) {
    self.getter = getter
    self.setter = setter
    var values = Array<CGFloat>(repeating:0, count: count)
    getter(&values)
    self.values = values
    self.target = target ?? values
    self.velocity = velocity ?? Array<CGFloat>(repeating:0, count: count)
    super.init(playImmediately: target != nil)
  }

  override public func didUpdate() {
    setter(&values)
  }
}
