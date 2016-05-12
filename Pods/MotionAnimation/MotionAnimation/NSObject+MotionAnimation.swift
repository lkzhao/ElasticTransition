//
//  NSObject+MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

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
  func m_defineCustomProperty<T:MotionAnimatableProperty>(key:String, initialValues:T, valueUpdateCallback:(T)->Void){
    if m_propertyStates[key] != nil{
      return
    }
    m_propertyStates[key] = MotionAnimationPropertyState(values: initialValues.CGFloatValues)
    getPropertyState(key).addValueUpdateCallback({ values in
      valueUpdateCallback(T.fromCGFloatValues(values))
    })
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
  func m_addValueUpdateCallback<T:MotionAnimatableProperty>(key:String, valueUpdateCallback:(T)->Void) -> MotionAnimationObserverKey{
    return getPropertyState(key).addValueUpdateCallback({ values in
      valueUpdateCallback(T.fromCGFloatValues(values))
    })
  }
  func m_addVelocityUpdateCallback<T:MotionAnimatableProperty>(key:String, velocityUpdateCallback:(T)->Void) -> MotionAnimationObserverKey{
    return getPropertyState(key).addVelocityUpdateCallback({ values in
      velocityUpdateCallback(T.fromCGFloatValues(values))
    })
  }
  func m_removeCallback(key:String, observerKey:MotionAnimationObserverKey){
    getPropertyState(key).removeCallback(observerKey)
  }
  
  func m_isAnimating(key:String) -> Bool{
    return getPropertyState(key).animation?.playing ?? false
  }
  
  func m_animate<T:MotionAnimatableProperty>(
    key:String,
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