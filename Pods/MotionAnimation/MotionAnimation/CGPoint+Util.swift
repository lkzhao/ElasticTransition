//
//  CGPoint+Util.swift
//  DynamicView
//
//  Created by YiLun Zhao on 2016-01-17.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

extension CGFloat{
  func clamp(a:CGFloat, _ b:CGFloat) -> CGFloat{
    return self < a ? a : (self > b ? b : self)
  }
}
extension CGPoint{
  func translate(dx:CGFloat, dy:CGFloat) -> CGPoint{
    return CGPointMake(self.x+dx, self.y+dy)
  }
  
  func transform(t:CGAffineTransform) -> CGPoint{
    return CGPointApplyAffineTransform(self, t)
  }
  
  func distance(b:CGPoint)->CGFloat{
    return sqrt(pow(self.x-b.x,2)+pow(self.y-b.y,2));
  }
}
func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPointMake(left.x + right.x, left.y + right.y)
}
func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPointMake(left.x - right.x, left.y - right.y)
}
func /(left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPointMake(left.x/right, left.y/right)
}
func *(left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPointMake(left.x*right, left.y*right)
}
func *(left: CGFloat, right: CGPoint) -> CGPoint {
  return right * left
}
