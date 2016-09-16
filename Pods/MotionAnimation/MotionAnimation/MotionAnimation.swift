//
//  MotionAnimation.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public protocol MotionAnimationDelegate:class {
  func animationDidStop(_ animation:MotionAnimation)
  func animationDidPerformStep(_ animation:MotionAnimation)
}

open class MotionAnimation: NSObject {
  internal var animator:MotionAnimator?

  weak open var delegate:MotionAnimationDelegate?
  open var onCompletion:((_ animation:MotionAnimation) -> Void)?
  open var onUpdate:((_ animation:MotionAnimation) -> Void)?
  open var willStartPlaying:(()->Void)? = nil

  open var playing:Bool {
    return animator != nil
  }

  public init(playImmediately:Bool = true) {
    super.init()
    if playImmediately { play() }
  }

  open func play(){
    if !playing{
      willStartPlaying?()
      MotionAnimator.sharedInstance.addAnimation(self)
    }
  }

  open func stop(){
    MotionAnimator.sharedInstance.removeAnimation(self)
  }
  
  
  
  // override point for subclass
  open func willUpdate() {}
  
  // returning true means require next update(not yet reached target state)
  // behaviors can call animator.addAnimation to wake up the animator when
  // the target value changed
  open func update(_ dt:CGFloat) -> Bool{
    return false
  }
  
  // this will be called on main thread. sync value back to the animated object
  open func didUpdate(){}
}
