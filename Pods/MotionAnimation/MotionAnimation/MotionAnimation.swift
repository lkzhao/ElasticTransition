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

public class MotionAnimation: NSObject {
  internal var animator:MotionAnimator?

  weak public var delegate:MotionAnimationDelegate?
  public var onCompletion:((animation:MotionAnimation) -> Void)?
  public var onUpdate:((animation:MotionAnimation) -> Void)?
  public var willStartPlaying:(()->Void)? = nil

  public var playing:Bool {
    return animator != nil
  }

  public init(playImmediately:Bool = true) {
    super.init()
    if playImmediately { play() }
  }

  public func play(){
    if !playing{
      willStartPlaying?()
      MotionAnimator.sharedInstance.addAnimation(self)
    }
  }

  public func stop(){
    MotionAnimator.sharedInstance.removeAnimation(self)
  }
}

// override point for subclass
extension MotionAnimation{
  public func willUpdate() {

  }

  // returning true means require next update(not yet reached target state)
  // behaviors can call animator.addAnimation to wake up the animator when
  // the target value changed
  public func update(_ dt:CGFloat) -> Bool{
    return false
  }

  // this will be called on main thread. sync value back to the animated object
  public func didUpdate(){

  }
}
