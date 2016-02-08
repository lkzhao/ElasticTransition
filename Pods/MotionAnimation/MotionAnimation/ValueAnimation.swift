//
//  ValueAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-18.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public typealias CGFloatValueGetterBlock = (() -> CGFloat)
public typealias CGFloatValueSetterBlock = ((CGFloat) -> Void)
public class ValueAnimation:MotionAnimation {
  public var getter:CGFloatValueGetterBlock?
  public var setter:CGFloatValueSetterBlock?
  public var target:CGFloat = 0{
    didSet{
      if target != getter?(){
        play()
      }
    }
  }
  public var velocity:CGFloat = 0
  
  public override init() {
    super.init()
  }
  
  public init(getter:CGFloatValueGetterBlock, setter:CGFloatValueSetterBlock, target:CGFloat) {
    super.init()
    self.getter = getter
    self.setter = setter
    self.target = target
  }
}

public typealias CGFloatValuesGetterBlock = (() -> [CGFloat])
public typealias CGFloatValuesSetterBlock = (([CGFloat]) -> Void)
public typealias ValueAnimationFactory = () -> ValueAnimation
public class MultiValueAnimation:MotionAnimation {
  public var getter:CGFloatValuesGetterBlock?
  public var setter:CGFloatValuesSetterBlock?
  public var target:[CGFloat] = [0]{
    didSet{
      loop { c, i in
        c.target = self.target[i]
      }
      play()
    }
  }
  
  public func loop(cb:((ValueAnimation, Int) -> Void)){
    for (i, c) in (childAnimations as! [ValueAnimation]).enumerate(){
      cb(c, i)
    }
  }
  
  public var velocity:[CGFloat]{
    var velocity:[CGFloat] = []
    velocity.reserveCapacity(childAnimations.count)
    loop { c, i in
      velocity.append(c.velocity)
    }
    return velocity
  }
  
  public var current:[CGFloat] = [0]
  
  public override func update(dt: CGFloat) -> Bool {
    if let p = getter?(){
      current = p
    }
    let running = super.update(dt)
    setter?(current)
    return running
  }
  
  public init(animationFactory:ValueAnimationFactory, getter:CGFloatValuesGetterBlock, setter:CGFloatValuesSetterBlock, target:[CGFloat]) {
    super.init()
    self.getter = getter
    self.setter = setter
    self.target = target
    self.current = getter()

    for (i, t) in target.enumerate(){
      let b = animationFactory()
      b.getter = {
        return self.current[i]
      }
      b.setter = {
        self.current[i] = $0
      }
      b.target = t
      addChildBehavior(b)
    }
  }
}
