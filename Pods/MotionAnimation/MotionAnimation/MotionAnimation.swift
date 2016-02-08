//
//  MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public protocol MotionAnimationDelegate{
  func animationDidStop(animation:MotionAnimation)
  func animationDidPerformStep(animation:MotionAnimation)
}

public class MotionAnimation: NSObject {
  internal var animator:MotionAnimator?
  internal weak var parentAnimation:MotionAnimation?
  internal var childAnimations:[MotionAnimation] = []
  
  public var delegate:MotionAnimationDelegate?
  public var onCompletion:((animation:MotionAnimation) -> Void)?
  public var onUpdate:((animation:MotionAnimation) -> Void)?

  public var playing:Bool{
    return MotionAnimator.sharedInstance.hasAnimation(self)
  }
  
  override init() {
    super.init()
    MotionAnimator.sharedInstance.addAnimation(self)
  }
  
  public func addChildBehavior(b:MotionAnimation){
    if childAnimations.indexOf(b) == nil{
      childAnimations.append(b)
      b.parentAnimation = self
    }
  }
  
  public func play(){
    if parentAnimation == nil{
      MotionAnimator.sharedInstance.addAnimation(self)
    }
  }
  
  public func stop(){
    if parentAnimation == nil{
      MotionAnimator.sharedInstance.removeAnimation(self)
    }
  }
  
  // returning true means require next update(not yet reached target state)
  // behaviors can call animator.addAnimation to wake up the animator when
  // the target value changed
  public func update(dt:CGFloat) -> Bool{
    var running = false
    for c in childAnimations{
      if c.update(dt){
        running = true
      }
    }
    return running
  }
}
