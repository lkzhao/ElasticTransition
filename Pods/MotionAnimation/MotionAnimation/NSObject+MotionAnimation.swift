//
//  NSObject+MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public extension NSObject{
  fileprivate struct m_associatedKeys {
    static var m_propertyStates = "m_propertyStates_key"
  }
  // use NSMutableDictionary since swift dictionary requires a O(n) dynamic cast even when using as!
  fileprivate var m_propertyStates:NSMutableDictionary{
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
  
  fileprivate func getPropertyState(_ key:String) -> MotionAnimationPropertyState{
    if m_propertyStates[key] == nil {
      if let animatable = self as? MotionAnimationAnimatable, let (getter, setter) = animatable.defaultGetterAndSetterForKey(key){
        m_propertyStates[key] = MotionAnimationPropertyState(getter: getter, setter: setter)
      } else {
        fatalError("\(key) is not animatable, you can define customAnimation property via m_defineCustomProperty or conform to MotionAnimationAnimatable")
      }
    }
    return m_propertyStates[key] as! MotionAnimationPropertyState
  }
  
  // define custom animatable property
  func m_setValues(_ values:[CGFloat], forCustomProperty key:String){
    getPropertyState(key).setValues(values)
  }
  func m_defineCustomProperty<T:MotionAnimatableProperty>(_ key:String, initialValues:T, valueUpdateCallback:@escaping (T)->Void){
    if m_propertyStates[key] != nil{
      return
    }
    m_propertyStates[key] = MotionAnimationPropertyState(values: initialValues.CGFloatValues)
    let _ = getPropertyState(key).addValueUpdateCallback({ values in
      valueUpdateCallback(T.fromCGFloatValues(values))
    })
  }
  func m_defineCustomProperty(_ key:String, getter:@escaping CGFloatValueBlock, setter:@escaping CGFloatValueBlock){
    if m_propertyStates[key] != nil{
      return
    }
    m_propertyStates[key] = MotionAnimationPropertyState(getter: getter, setter: setter)
  }
  func m_removeAnimationForKey(_ key:String){
    getPropertyState(key).stop()
  }
  
  // add callbacks
  @discardableResult func m_addValueUpdateCallback<T:MotionAnimatableProperty>(_ key:String, valueUpdateCallback:@escaping (T)->Void) -> MotionAnimationObserverKey{
    return getPropertyState(key).addValueUpdateCallback({ values in
      valueUpdateCallback(T.fromCGFloatValues(values))
    })
  }
  @discardableResult func m_addVelocityUpdateCallback<T:MotionAnimatableProperty>(_ key:String, velocityUpdateCallback:@escaping (T)->Void) -> MotionAnimationObserverKey{
    return getPropertyState(key).addVelocityUpdateCallback({ values in
      velocityUpdateCallback(T.fromCGFloatValues(values))
    })
  }
  func m_removeCallback(_ key:String, observerKey:MotionAnimationObserverKey){
    let _ = getPropertyState(key).removeCallback(observerKey)
  }
  
  func m_isAnimating(_ key:String) -> Bool{
    return getPropertyState(key).animation?.playing ?? false
  }
  
  func m_animate<T:MotionAnimatableProperty>(
    _ key:String,
    to:T,
    stiffness:CGFloat? = nil,
    damping:CGFloat? = nil,
    threshold:CGFloat? = nil,
    valueUpdate:((T) -> Void)? = nil,
    velocityUpdate:((T) -> Void)? = nil,
    completion:(() -> Void)? = nil) {
    let valueOb:MotionAnimationValueObserver? = valueUpdate == nil ? nil : { values in
      valueUpdate!(T.fromCGFloatValues(values))
    }
    let velocityOb:MotionAnimationValueObserver? = velocityUpdate == nil ? nil : { values in
      velocityUpdate!(T.fromCGFloatValues(values))
    }
    getPropertyState(key)
      .animate(to.CGFloatValues,
               stiffness: stiffness,
               damping: damping,
               threshold: threshold,
               valueUpdate:valueOb,
               velocityUpdate:velocityOb,
               completion: completion)
  }
}
