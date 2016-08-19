//
//  MotionAnimator.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
@objc
public protocol MotionAnimatorObserver{
  func animatorDidUpdate(_ animator:MotionAnimator, dt:CGFloat)
}

public class MotionAnimator: NSObject {
  public static let sharedInstance = MotionAnimator()
  var updateObservers:[MotionAnimationObserverKey:Weak<MotionAnimatorObserver>] = [:]

  public var debugEnabled = false
  var displayLinkPaused:Bool{
    get{
      return displayLink == nil
    }
    set{
      newValue ? stop() : start()
    }
  }
  var animations:[MotionAnimation] = []
  var pendingStopAnimations:[MotionAnimation] = []
  var displayLink : CADisplayLink!

  override init(){
    super.init()
  }

  func update() {
    _removeAllPendingStopAnimations()

    let duration = CGFloat(displayLink.duration)
    for b in animations{
      b.willUpdate()
      if !b.update(duration){
        b.animator = nil
        pendingStopAnimations.append(b)
      }
      b.didUpdate()
      b.delegate?.animationDidPerformStep(b)
      b.onUpdate?(animation: b)
    }

    _removeAllPendingStopAnimations()

    if animations.count == 0{
      displayLinkPaused = true
    }
    for (_, o) in updateObservers{
      o.value?.animatorDidUpdate(self, dt: duration)
    }
  }

  // must be called in mutex
  func _removeAllPendingStopAnimations(){
    for b in pendingStopAnimations{
      if let index = animations.index(of: b){
        animations.remove(at: index)
        b.delegate?.animationDidStop(b)
        b.onCompletion?(animation: b)
      }
    }
    pendingStopAnimations.removeAll()
  }

  public func addUpdateObserver(_ observer:MotionAnimatorObserver) -> MotionAnimationObserverKey {
    let key = UUID()
    updateObservers[key] = Weak(value: observer)
    return key
  }

  public func observerWithKey(_ observerKey:MotionAnimationObserverKey) -> MotionAnimatorObserver? {
    return updateObservers[observerKey]?.value
  }

  public func removeUpdateObserverWithKey(_ observerKey:MotionAnimationObserverKey) {
    updateObservers.removeValue(forKey: observerKey)
  }

  public func addAnimation(_ b:MotionAnimation){
    if let index = pendingStopAnimations.index(of: b){
      pendingStopAnimations.remove(at: index)
    }
    if animations.index(of: b) == nil {
      animations.append(b)
      if displayLinkPaused {
        displayLinkPaused = false
      }
    }
    b.animator = self
  }
  public func hasAnimation(_ b:MotionAnimation) -> Bool{
    return animations.index(of: b) != nil && pendingStopAnimations.index(of: b) == nil
  }
  public func removeAnimation(_ b:MotionAnimation){
    if animations.index(of: b) != nil {
      pendingStopAnimations.append(b)
    }
    b.animator = nil
  }

  func start() {
    if !displayLinkPaused{
      return
    }
    displayLink = CADisplayLink(target: self, selector: #selector(update))
    displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    printDebugMsg("displayLink started")
  }

  func stop() {
    if displayLinkPaused{
      return
    }
    displayLink.isPaused = true
    displayLink.remove(from: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    displayLink = nil
    printDebugMsg("displayLink ended")
  }

  func printDebugMsg(_ str:String){
    if debugEnabled { print(str) }
  }
}




