//
//  MotionAnimationPropertyState.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-22.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit


/*
 *
 */

internal class MotionAnimationPropertyState:NSObject, MotionAnimationDelegate{

  var velocityUpdateCallbacks:[UUID:MotionAnimationValueObserver] = [:]
  var valueUpdateCallbacks:[UUID:MotionAnimationValueObserver] = [:]

  var animation:MotionAnimation?

  private var getter:CGFloatValueBlock?
  private var setter:CGFloatValueBlock?
  private var values:[CGFloat]?

  init(values:[CGFloat]){
    self.values = values
  }

  init(getter:CGFloatValueBlock, setter:CGFloatValueBlock){
    self.getter = getter
    self.setter = setter
  }

  private var _tempVelocityUpdate: MotionAnimationValueObserver?
  private var _tempValueUpdate: MotionAnimationValueObserver?
  private var _tempCompletion: (() -> Void)?
  func animate(
    _ toValues:[CGFloat],
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationValueObserver? = nil,
    completion:(() -> Void)? = nil) {

    let anim:SpringValueAnimation
    if let animation = animation as? SpringValueAnimation{
      anim = animation
    }else{
      animation?.stop()
      if let getter = getter, let setter = setter {
        anim = SpringValueAnimation(count: toValues.count, getter: getter, setter: setter)
      } else {
        anim = SpringValueAnimation(count: toValues.count, getter: { [weak self] newValues in
          if let values = self?.values{
            for i in 0..<values.count{
              newValues[i] = values[i]
            }
          }
        }, setter: { [weak self] newValues in
          self?.values = newValues
        })
      }
      animation = anim
    }
    if damping != nil || stiffness != nil || threshold != nil{
        anim.damping = damping ?? anim.damping
        anim.stiffness = stiffness ?? anim.stiffness
        anim.threshold = threshold ?? anim.threshold
    }

    _tempVelocityUpdate = velocityUpdate
    _tempValueUpdate = valueUpdate
    _tempCompletion = completion
    anim.delegate = self
    anim.target = toValues
  }

  func stop() {
    animation?.stop()
  }

  func addVelocityUpdateCallback(_ velocityUpdateCallback:MotionAnimationValueObserver) -> MotionAnimationObserverKey{
    let uuid = UUID()
    self.velocityUpdateCallbacks[uuid] = velocityUpdateCallback
    return uuid
  }

  func addValueUpdateCallback(_ valueUpdateCallback:MotionAnimationValueObserver) -> MotionAnimationObserverKey{
    let uuid = UUID()
    self.valueUpdateCallbacks[uuid] = valueUpdateCallback
    return uuid
  }

  func removeCallback(_ key:MotionAnimationObserverKey) -> MotionAnimationValueObserver? {
    return self.valueUpdateCallbacks.removeValue(forKey: key as UUID) ?? self.velocityUpdateCallbacks.removeValue(forKey: key as UUID)
  }

  internal func setValues(_ values:[CGFloat]){
    var values = values
    if let setter = setter{
        setter(&values)
    } else {
        self.values = values
    }
  }

  internal func animationDidStop(_ animation:MotionAnimation){
    _tempValueUpdate = nil
    _tempVelocityUpdate = nil
    if let _tempCompletion = _tempCompletion{
      self._tempCompletion = nil
      _tempCompletion()
    }
  }

  internal func animationDidPerformStep(_ animation:MotionAnimation){
    let animation = animation as! SpringValueAnimation
    if velocityUpdateCallbacks.count > 0 || _tempVelocityUpdate != nil{
      let v = animation.velocity
      for (_, callback) in velocityUpdateCallbacks{
        callback(v)
      }
      _tempVelocityUpdate?(v)
    }
    for (_, callback) in valueUpdateCallbacks{
      callback(animation.values)
    }
    if let _tempValueUpdate = _tempValueUpdate{
      _tempValueUpdate(animation.values)
    }
  }
}
