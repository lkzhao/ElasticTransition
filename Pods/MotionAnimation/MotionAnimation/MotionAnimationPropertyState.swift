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

internal class MotionAnimationPropertyState: MotionAnimationDelegate{
  private enum ValueStore{
    case ObjectKeyPath(obj:NSObject, keyPath:String)
    case Values(values:[CGFloat])
    func valuesWithType(type:MotionAnimationValueType) -> [CGFloat]{
      switch self{
      case .ObjectKeyPath(let obj, let keyPath):
        let v = obj.valueForKeyPath(keyPath)!
        return MotionAnimationValue.valueFromRawValue(v, withType: type).getCGFloatValues()
      case .Values(let values):
        return values
      }
    }
    mutating func setValue(values:[CGFloat], withType type:MotionAnimationValueType){
      let value = MotionAnimationValue.valueFromCGFloatValues(values, withType: type)
      switch self{
      case .ObjectKeyPath(let obj, let keyPath):
        obj.setValue(value.rawValue(), forKey: keyPath)
      case .Values:
        self = .Values(values: value.getCGFloatValues())
      }
    }
  }
  var velocityUpdateCallbacks:[NSUUID:MotionAnimationVelocityObserver] = [:]
  var valueUpdateCallbacks:[NSUUID:MotionAnimationValueObserver] = [:]
  
  var animation:MotionAnimation?
  
  private var _objectKeyPath:(NSObject, String)?
  private var valueStore:ValueStore
  
  init(values:[CGFloat]){
    valueStore = .Values(values: values)
  }
  
  init(obj:NSObject, keyPath:String){
    valueStore = .ObjectKeyPath(obj: obj, keyPath: keyPath)
  }
  
  private var _tempVelocityUpdate: MotionAnimationVelocityObserver?
  private var _tempValueUpdate: MotionAnimationValueObserver?
  private var _tempCompletion: (() -> Void)?
  func animate(
    toValues:MotionAnimationValue,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      
      let anim:MultiValueAnimation
      if let animation = animation as? MultiValueAnimation{
        anim = animation
        if damping != nil || stiffness != nil || threshold != nil{
          anim.loop{ childAnimation, i in
            if let spring = childAnimation as? SpringValueAnimation{
              spring.damping = damping ?? spring.damping
              spring.stiffness = stiffness ?? spring.stiffness
              spring.threshold = threshold ?? spring.threshold
            }
          }
        }
      }else{
        animation?.stop()
        anim = MultiValueAnimation(animationFactory: {
          let spring = SpringValueAnimation()
          spring.damping = damping ?? spring.damping
          spring.stiffness = stiffness ?? spring.stiffness
          spring.threshold = threshold ?? spring.threshold
          return spring
          }, getter: {
            return self.valueStore.valuesWithType(toValues.type)
          }, setter: { newValues in
            self.valueStore.setValue(newValues, withType: toValues.type)
          }, target: toValues.getCGFloatValues())
        animation = anim
      }
      _tempVelocityUpdate = velocityUpdate
      _tempValueUpdate = valueUpdate
      _tempCompletion = completion
      anim.delegate = self
      anim.target = toValues.getCGFloatValues()
  }
  
  func addVelocityUpdateCallback(velocityUpdateCallback:MotionAnimationVelocityObserver) -> MotionAnimationObserverKey{
    let uuid = NSUUID()
    self.velocityUpdateCallbacks[uuid] = velocityUpdateCallback
    return uuid
  }
  
  func addValueUpdateCallback(valueUpdateCallback:MotionAnimationValueObserver) -> MotionAnimationObserverKey{
    let uuid = NSUUID()
    self.valueUpdateCallbacks[uuid] = valueUpdateCallback
    return uuid
  }
  
  func removeCallback(key:MotionAnimationObserverKey) -> MotionAnimationValueObserver? {
    return self.valueUpdateCallbacks.removeValueForKey(key) ?? self.velocityUpdateCallbacks.removeValueForKey(key)
  }
  
  internal func setValues(values:[CGFloat]){
    self.valueStore.setValue(values, withType: .CGFloatMultiValue)
  }

  internal func animationDidStop(animation:MotionAnimation){
    _tempValueUpdate = nil
    _tempVelocityUpdate = nil
    if let _tempCompletion = _tempCompletion{
      self._tempCompletion = nil
      _tempCompletion()
    }
  }
  
  internal func animationDidPerformStep(animation:MotionAnimation){
    if velocityUpdateCallbacks.count > 0 || _tempVelocityUpdate != nil{
      let v = (animation as! MultiValueAnimation).velocity
      for (_, callback) in velocityUpdateCallbacks{
        callback.executeWithValues(v)
      }
      _tempVelocityUpdate?.executeWithValues(v)
    }
    valueUpdated()
  }
  
  internal func valueUpdated(){
    for (_, callback) in valueUpdateCallbacks{
      callback.executeWithValues(valueStore.valuesWithType(callback.valueType))
    }
    if let _tempValueUpdate = _tempValueUpdate{
      _tempValueUpdate.executeWithValues(valueStore.valuesWithType(_tempValueUpdate.valueType))
    }
  }
}