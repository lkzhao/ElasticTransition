//
//  NSObject+MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class MotionAnimationMultiValueObserver:NSObject, MotionAnimatorObserver{
  var observedKeys:[NSObject:[String:MotionAnimationObserverKey]]!

  var _updatedKeys:[NSObject:[String]] = [:]

  var callback:((updatedObjectAndKeys:[NSObject:[String]])->Void)!
  func object(object:NSObject, didUpdateKey key:String){
    if observedKeys[object]?[key] != nil{
      if _updatedKeys[object] == nil{
        _updatedKeys[object] = []
      }
      _updatedKeys[object]!.append(key)
    }
  }
  func cleanup(){
    for (o, callbacks) in observedKeys{
      for (key, observerKey) in callbacks{
        o.m_removeCallback(key, observerKey: observerKey)
      }
    }
  }
  func animatorDidUpdate(animator: MotionAnimator, dt: CGFloat) {
    callback(updatedObjectAndKeys:_updatedKeys)
    _updatedKeys = [:]
  }
}


public protocol MotionAnimationAnimatable {
  func defaultGetterAndSetterForKey(key:String) -> (CGFloatValueBlock, CGFloatValueBlock)?
}

extension UIView:MotionAnimationAnimatable{
  public func defaultGetterAndSetterForKey(key: String) -> (CGFloatValueBlock, CGFloatValueBlock)? {
    switch key {
    case "bounds":
      return ({ [weak self] values in
        self?.bounds.toCGFloatValues(&values)
      }, { [weak self] values in
        self?.bounds = CGRect.fromCGFloatValues(values)
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

public extension NSObject{
  private struct m_associatedKeys {
    static var m_propertyStates = "m_propertyStates_key"
  }
  // use NSMutableDictionary since swift dictionary requires a O(n) dynamic cast even when using as!
  private var m_propertyStates:NSMutableDictionary{
    get {
      // never use `as?` in this case. it is very expensive
      let rtn = objc_getAssociatedObject(self, &m_associatedKeys.m_propertyStates)
      if rtn != nil{
        return rtn as! NSMutableDictionary
      }
      self.m_propertyStates = NSMutableDictionary()
      return objc_getAssociatedObject(self, &m_associatedKeys.m_propertyStates) as! NSMutableDictionary
    }
    set {
      objc_setAssociatedObject(
        self,
        &m_associatedKeys.m_propertyStates,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
  
  private func getPropertyState(key:String) -> MotionAnimationPropertyState{
    if m_propertyStates[key] == nil {
      if let animatable = self as? MotionAnimationAnimatable, (getter, setter) = animatable.defaultGetterAndSetterForKey(key){
        m_propertyStates[key] = MotionAnimationPropertyState(getter: getter, setter: setter)
      } else {
        fatalError("\(key) is not animatable, you can define customAnimation property via m_defineCustomProperty or conform to MotionAnimationAnimatable")
      }
    }
    return m_propertyStates[key] as! MotionAnimationPropertyState
  }
  
  // define custom animatable property
  func m_setValues(values:[CGFloat], forCustomProperty key:String){
    getPropertyState(key).setValues(values)
  }
  func m_defineCustomProperty(key:String, initialValues:MotionAnimatableProperty, valueUpdateCallback:MotionAnimationValueObserver){
    if m_propertyStates[key] != nil{
      return
    }
    m_propertyStates[key] = MotionAnimationPropertyState(values: initialValues.CGFloatValues)
    getPropertyState(key).addValueUpdateCallback(valueUpdateCallback)
  }
  func m_defineCustomProperty(key:String, getter:CGFloatValueBlock, setter:CGFloatValueBlock){
    if m_propertyStates[key] != nil{
      return
    }
    m_propertyStates[key] = MotionAnimationPropertyState(getter: getter, setter: setter)
  }
  func m_removeAnimationForKey(key:String){
    getPropertyState(key).stop()
  }
  
  // add callbacks
  func m_addValueUpdateCallback(key:String, valueUpdateCallback:MotionAnimationValueObserver) -> MotionAnimationObserverKey{
    return getPropertyState(key).addValueUpdateCallback(valueUpdateCallback)
  }
  func m_addVelocityUpdateCallback(key:String, velocityUpdateCallback:MotionAnimationValueObserver) -> MotionAnimationObserverKey{
    return getPropertyState(key).addVelocityUpdateCallback(velocityUpdateCallback)
  }

  static func m_addCallbackForAnyValueUpdated(objects:[NSObject:[String]], callback:(([NSObject:[String]]) ->Void) ) -> MotionAnimationObserverKey{
    let multiValueOb = MotionAnimationMultiValueObserver()
    multiValueOb.callback = callback
    var observedKeys:[NSObject:[String:MotionAnimationObserverKey]] = [:]
    for (o, keys) in objects{
      var observedKeysForObject:[String:MotionAnimationObserverKey] = [:]
      for key in keys{
        observedKeysForObject[key] = o.getPropertyState(key).addValueUpdateCallback({ _ in
          multiValueOb.object(o, didUpdateKey: key)
        })
      }
      observedKeys[o] = observedKeysForObject
    }
    multiValueOb.observedKeys = observedKeys;
    return MotionAnimator.sharedInstance.addUpdateObserver(multiValueOb)
  }
  static func m_removeMultiValueObserver(observerKey:MotionAnimationObserverKey){
    if let multiValueOb = MotionAnimator.sharedInstance.observerWithKey(observerKey) as? MotionAnimationMultiValueObserver{
      MotionAnimator.sharedInstance.removeUpdateObserverWithKey(observerKey)
      multiValueOb.cleanup()
    }
  }
  
  func m_removeCallback(key:String, observerKey:MotionAnimationObserverKey){
    getPropertyState(key).removeCallback(observerKey)
  }
  
  // animation
  func m_delay(time:NSTimeInterval, completion:(() -> Void)){
    NSTimer.schedule(delay: time) { timer in
      completion()
    }
  }

  func m_isAnimating(key:String) -> Bool{
    return getPropertyState(key).animation?.playing ?? false
  }

  func m_animate(
    key:String,
    to:MotionAnimatableProperty,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
    getPropertyState(key).animate(to.CGFloatValues, stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
}