//
//  Types.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-22.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public typealias MotionAnimationObserverKey = NSUUID

public enum MotionAnimationValueObserver{
  case CGFloatObserver((CGFloat) -> Void)
  case CGRectObserver((CGRect) -> Void)
  case CGPointObserver((CGPoint) -> Void)
  case CGFloatMultiObserver(([CGFloat]) -> Void)
  case UIColorObserver((UIColor) -> Void)
  case Observer(() -> Void)

  public var valueType:MotionAnimationValueType{
    switch self{
    case .CGFloatObserver:
      return .CGFloatValue
    case .CGRectObserver:
      return .CGRectValue
    case .CGPointObserver:
      return .CGPointValue
    case .CGFloatMultiObserver:
      return .CGFloatMultiValue
    case .UIColorObserver:
      return .UIColorValue
    case .Observer:
      return .NoValue
    }
  }
  
  public func executeWithValues(values:[CGFloat]){
    switch self{
    case .CGFloatObserver(let cb):
      cb(values[0])
    case .CGPointObserver(let cb):
      cb(CGPointMake(values[0],values[1]))
    case .CGRectObserver(let cb):
      cb(CGRectMake(values[0],values[1],values[2],values[3]))
    case .CGFloatMultiObserver(let cb):
      cb(values)
    case .UIColorObserver(let cb):
      cb(UIColor(red: values[0], green: values[1], blue: values[2], alpha: values[3]))
    case .Observer(let cb):
      cb()
    }
  }
}

public enum MotionAnimationValueType{
  case CGFloatValue
  case CGRectValue
  case CGPointValue
  case CGFloatMultiValue
  case UIColorValue
  case NoValue
}
public enum MotionAnimationValue{
  case CGFloatValue(CGFloat)
  case CGRectValue(CGRect)
  case CGPointValue(CGPoint)
  case CGFloatMultiValue([CGFloat])
  case UIColorValue(UIColor)
  case NoValue()
  
  public static func valueFromCGFloatValues(values:[CGFloat], withType type:MotionAnimationValueType) -> MotionAnimationValue{
    switch type{
    case .CGFloatValue:
      return .CGFloatValue(values[0])
    case .CGRectValue:
      return .CGRectValue(CGRectMake(values[0],values[1],values[2],values[3]))
    case .CGPointValue:
      return .CGPointValue(CGPointMake(values[0],values[1]))
    case .CGFloatMultiValue:
      return .CGFloatMultiValue(values)
    case .UIColorValue:
      return .UIColorValue(UIColor(red: values[0], green: values[1], blue: values[2], alpha: values[3]))
    case .NoValue:
      return .NoValue()
    }
  }
  public static func valueFromRawValue(value:AnyObject, withType type:MotionAnimationValueType) -> MotionAnimationValue{
    switch type{
    case .CGFloatValue:
      return .CGFloatValue(CGFloat(value.floatValue!))
    case .CGRectValue:
      return .CGRectValue(value.CGRectValue!)
    case .CGPointValue:
      return .CGPointValue(value.CGPointValue)
    case .CGFloatMultiValue:
      return .CGFloatMultiValue(value as! [CGFloat])
    case .UIColorValue:
      return .UIColorValue(value as! UIColor)
    case .NoValue:
      return .NoValue()
    }
  }
  public var type:MotionAnimationValueType{
    switch self{
    case .CGFloatValue:
      return .CGFloatValue
    case .CGRectValue:
      return .CGRectValue
    case .CGPointValue:
      return .CGPointValue
    case .CGFloatMultiValue:
      return .CGFloatMultiValue
    case .UIColorValue:
      return .UIColorValue
    case .NoValue:
      return .NoValue
    }
  }
  public func getCGFloatValues() -> [CGFloat]{
    switch self{
    case .CGFloatValue(let v):
      return [v]
    case .CGRectValue(let v):
      return [v.origin.x, v.origin.y, v.width, v.height]
    case .CGPointValue(let v):
      return [v.x, v.y]
    case .CGFloatMultiValue(let v):
      return v
    case .UIColorValue(let v):
      var r : CGFloat = 0
      var g : CGFloat = 0
      var b : CGFloat = 0
      var a : CGFloat = 0
      v.getRed(&r, green: &g, blue: &b, alpha: &a)
      return [r,g,b,a]
    case .NoValue:
      return []
    }
  }
  public func rawValue() -> AnyObject!{
    switch self{
    case .CGFloatValue(let v):
      return v
    case .CGRectValue(let v):
      return NSValue(CGRect: v)
    case .CGPointValue(let v):
      return NSValue(CGPoint: v)
    case .CGFloatMultiValue(let v):
      return v
    case .UIColorValue(let v):
      return v
    case .NoValue:
      return nil
    }
  }
}

public typealias MotionAnimationVelocityObserver = MotionAnimationValueObserver
