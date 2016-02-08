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

public extension NSObject{
  private struct m_associatedKeys {
    static var m_propertyStates = "m_propertyStates_key"
    static var m_multiValueObservers = "m_multiValueObservers_key"
  }
  private var m_propertyStates:[String:MotionAnimationPropertyState]{
    get {
      if let rtn = objc_getAssociatedObject(self, &m_associatedKeys.m_propertyStates) as? [String:MotionAnimationPropertyState]{
        return rtn
      }
      self.m_propertyStates = [:]
      return objc_getAssociatedObject(self, &m_associatedKeys.m_propertyStates) as! [String:MotionAnimationPropertyState]
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
  private var m_multiValueObservers:[MotionAnimationObserverKey:MotionAnimationMultiValueObserver]{
    get {
      if let rtn = objc_getAssociatedObject(self, &m_associatedKeys.m_propertyStates) as? [MotionAnimationObserverKey:MotionAnimationMultiValueObserver]{
        return rtn
      }
      self.m_propertyStates = [:]
      return objc_getAssociatedObject(self, &m_associatedKeys.m_propertyStates) as! [MotionAnimationObserverKey:MotionAnimationMultiValueObserver]
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
      m_propertyStates[key] = MotionAnimationPropertyState(obj: self, keyPath: key)
    }
    return m_propertyStates[key]!
  }
  
  // define custom animatable property
  func m_setValues(values:[CGFloat], forCustomProperty key:String){
    getPropertyState(key).setValues(values)
  }
  func m_defineCustomProperty(key:String, initialValues:[CGFloat], valueUpdateCallback:CGFloatValuesSetterBlock){
    if m_propertyStates[key] != nil{
      return
    }
    m_propertyStates[key] = MotionAnimationPropertyState(values: initialValues)
    getPropertyState(key).addValueUpdateCallback(.CGFloatMultiObserver(valueUpdateCallback))
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
        observedKeysForObject[key] = o.getPropertyState(key).addValueUpdateCallback(.Observer({ _ in
          multiValueOb.object(o, didUpdateKey: key)
        }))
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
  func m_animate(
    key:String,
    to:UIColor,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.UIColorValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:CGFloat,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.CGFloatValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:[CGFloat],
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.CGFloatMultiValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:CGRect,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.CGRectValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:CGPoint,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(.CGPointValue(to), stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
  func m_animate(
    key:String,
    to:MotionAnimationValue,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:MotionAnimationValueObserver? = nil,
    velocityUpdate:MotionAnimationVelocityObserver? = nil,
    completion:(() -> Void)? = nil) {
      getPropertyState(key).animate(to, stiffness: stiffness, damping: damping, threshold: threshold, valueUpdate:valueUpdate, velocityUpdate:velocityUpdate, completion: completion)
  }
}