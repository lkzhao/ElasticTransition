//
//  Types.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-22.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public typealias MotionAnimationObserverKey = NSUUID

public typealias MotionAnimationValueObserver = ([CGFloat]) -> Void
public typealias MotionAnimationVelocityObserver = MotionAnimationValueObserver

public func CGPointObserver(ob:(CGPoint) -> Void) -> MotionAnimationValueObserver{
  return { values in
    ob(CGPointMake(values[0], values[1]))
  }
}

public protocol MotionAnimatableProperty{
  var CGFloatValues:[CGFloat] { get }
  static func fromCGFloatValues(values:[CGFloat]) -> Self
  func toCGFloatValues(inout values:[CGFloat])
}

extension UIColor:MotionAnimatableProperty{
  public var CGFloatValues:[CGFloat] {
    var r : CGFloat = 0
    var g : CGFloat = 0
    var b : CGFloat = 0
    var a : CGFloat = 0
    self.getRed(&r, green: &g, blue: &b, alpha: &a)
    return [r,g,b,a]
  }
  public static func fromCGFloatValues(values: [CGFloat]) -> Self {
    return self.init(red: values[0], green: values[1], blue: values[2], alpha: values[3])
  }
  public func toCGFloatValues(inout values: [CGFloat]) {
    self.getRed(&values[0], green: &values[1], blue: &values[2], alpha: &values[3])
  }
}

extension CGRect:MotionAnimatableProperty{
  public var CGFloatValues:[CGFloat] {
    return [self.origin.x, self.origin.y, self.width, self.height]
  }
  public static func fromCGFloatValues(values: [CGFloat]) -> CGRect {
    return CGRectMake(values[0],values[1],values[2],values[3])
  }
  public func toCGFloatValues(inout values: [CGFloat]) {
    values[0] = self.origin.x
    values[1] = self.origin.y
    values[2] = self.width
    values[3] = self.height
  }
}

extension Double:MotionAnimatableProperty{
    public var CGFloatValues:[CGFloat] {
        return [CGFloat(self)]
    }
    public static func fromCGFloatValues(values: [CGFloat]) -> Double {
        return Double(values[0])
    }
    public func toCGFloatValues(inout values: [CGFloat]) {
        values[0] = CGFloat(self)
    }
}
extension CGFloat:MotionAnimatableProperty{
  public var CGFloatValues:[CGFloat] {
    return [self]
  }
  public static func fromCGFloatValues(values: [CGFloat]) -> CGFloat {
    return values[0]
  }
  public func toCGFloatValues(inout values: [CGFloat]) {
    values[0] = self
  }
}

extension Int:MotionAnimatableProperty{
    public var CGFloatValues: [CGFloat]{
        return CGFloat(self).CGFloatValues
    }
    public static func fromCGFloatValues(values: [CGFloat]) -> Int {
        return Int(values[0])
    }
    public func toCGFloatValues(inout values: [CGFloat]) {
        values[0] = CGFloat(self)
    }
}

extension CGPoint:MotionAnimatableProperty{
  public var CGFloatValues:[CGFloat] {
    return [self.x, self.y]
  }
  public static func fromCGFloatValues(values: [CGFloat]) -> CGPoint {
    return CGPointMake(values[0], values[1])
  }
  public func toCGFloatValues(inout values: [CGFloat]) {
    values[0] = self.x
    values[1] = self.y
  }
}

extension CGSize:MotionAnimatableProperty{
  public var CGFloatValues:[CGFloat] {
    return [self.width, self.height]
  }
  public static func fromCGFloatValues(values: [CGFloat]) -> CGSize {
    return CGSizeMake(values[0], values[1])
  }
  public func toCGFloatValues(inout values: [CGFloat]) {
    values[0] = self.width
    values[1] = self.height
  }
}

