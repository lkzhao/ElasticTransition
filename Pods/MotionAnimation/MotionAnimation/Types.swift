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

public protocol MotionAnimationAnimatable {
  func defaultGetterAndSetterForKey(key:String) -> (CGFloatValueBlock, CGFloatValueBlock)?
}

class Weak<T: AnyObject> {
  weak var value : T?
  init (value: T) {
    self.value = value
  }
}

extension UIView:MotionAnimationAnimatable{
  public func defaultGetterAndSetterForKey(key: String) -> (CGFloatValueBlock, CGFloatValueBlock)? {
    switch key {
    case "frame", "bounds":
      return ({ [weak self] values in
        self?.valueForKey(key)?.CGRectValue().toCGFloatValues(&values)
        }, { [weak self] values in
          self?.setValue(NSValue(CGRect:CGRect.fromCGFloatValues(values)), forKey: key)
        })
    case "backgroundColor", "tintColor":
      return ({ [weak self] values in
        (self?.valueForKey(key) as? UIColor)?.toCGFloatValues(&values)
        }, { [weak self] values in
          self?.setValue(UIColor.fromCGFloatValues(values), forKey: key)
        })
    case "center":
      return ({ [weak self] values in
        self?.center.toCGFloatValues(&values)
        }, { [weak self] values in
          self?.center = CGPoint.fromCGFloatValues(values)
        })
    case "alpha":
      return ({ [weak self] values in
        self?.alpha.toCGFloatValues(&values)
        }, { [weak self] values in
          self?.alpha = CGFloat.fromCGFloatValues(values)
        })
    case "scale", "scale.x", "scale.y", "scale.z", "rotation", "rotation.x", "rotation.y", "rotation.z", "translation.x", "translation.y", "translation.z":
      return ({ [weak self] values in
        self?.valueForKeyPath("layer.transform.\(key)")?.doubleValue.toCGFloatValues(&values)
        }, { [weak self] values in
          self?.setValue(Double.fromCGFloatValues(values), forKeyPath: "layer.transform.\(key)")
        })
    default:
      return nil
    }
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

