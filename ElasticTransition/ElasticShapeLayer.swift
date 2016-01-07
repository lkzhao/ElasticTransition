/*

The MIT License (MIT)

Copyright (c) 2015 Luke Zhao <me@lkzhao.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import UIKit



public class ElasticShapeLayer: CAShapeLayer {
  public var edge:Edge = .Bottom{
    didSet{
      path = currentPath()
    }
  }
  public var dragPoint:CGPoint = CGPointZero{
    didSet{
      path = currentPath()
    }
  }
  
  public var radiusFactor:CGFloat = 0.25{
    didSet{
      if radiusFactor < 0{
        radiusFactor = 0
      }
    }
  }
  
  override public init() {
    super.init()
    
    backgroundColor = UIColor.clearColor().CGColor
    fillColor = UIColor.blackColor().CGColor
    actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull(), "fillColor" : NSNull()]
  }
  override public init(layer: AnyObject) {
    super.init(layer: layer)
  }

  required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  private func currentPath() -> CGPath {
    var centerPoint = dragPoint
    
    let leftPoint:CGPoint,rightPoint:CGPoint,bottomRightPoint:CGPoint,bottomLeftPoint:CGPoint
    switch edge{
    case .Top:
      leftPoint = CGPointMake(0 - max(0,bounds.width/2 - dragPoint.x), bounds.minY)
      rightPoint = CGPointMake(bounds.width + max(0,dragPoint.x-bounds.width/2), bounds.minY)
      bottomRightPoint = CGPointMake(bounds.maxX, bounds.maxY)
      bottomLeftPoint = CGPointMake(bounds.minX, bounds.maxY)
    case .Bottom:
      leftPoint = CGPointMake(bounds.width + max(0,dragPoint.x-bounds.width/2), bounds.maxY)
      rightPoint = CGPointMake(0 - max(0,bounds.width/2 - dragPoint.x), bounds.maxY)
      bottomRightPoint = CGPointMake(bounds.minX, bounds.minY)
      bottomLeftPoint = CGPointMake(bounds.maxX, bounds.minY)
    case .Left:
      leftPoint = CGPointMake(bounds.minX, bounds.height + max(0,dragPoint.y-bounds.height/2))
      rightPoint = CGPointMake(bounds.minX, 0 - max(0,bounds.height/2 - dragPoint.y))
      bottomRightPoint = CGPointMake(bounds.maxX, bounds.minY)
      bottomLeftPoint = CGPointMake(bounds.maxX, bounds.maxY)
    case .Right:
      leftPoint = CGPointMake(bounds.maxX, 0 - max(0,bounds.height/2 - dragPoint.y))
      rightPoint = CGPointMake(bounds.maxX, bounds.height + max(0,dragPoint.y-bounds.height/2))
      bottomRightPoint = CGPointMake(bounds.minX, bounds.maxY)
      bottomLeftPoint = CGPointMake(bounds.minX, bounds.minY)
    }
    
    let shapePath = UIBezierPath()
    shapePath.moveToPoint(leftPoint)
    
    if radiusFactor>=0.5{
      let rightControl:CGPoint,leftControl:CGPoint;
      switch edge{
      case .Top,.Bottom:
        rightControl = CGPointMake((rightPoint.x - centerPoint.x)*0.8+centerPoint.x, centerPoint.y)
        leftControl = CGPointMake((centerPoint.x - leftPoint.x)*0.2+leftPoint.x, centerPoint.y)
      case .Left,.Right:
        rightControl = CGPointMake(centerPoint.x, (rightPoint.y - centerPoint.y)*0.8+centerPoint.y)
        leftControl = CGPointMake(centerPoint.x, (centerPoint.y - leftPoint.y)*0.2+leftPoint.y)
      }
      
      shapePath.addCurveToPoint(
        centerPoint,
        controlPoint1: leftPoint,
        controlPoint2: leftControl)
      
      shapePath.addCurveToPoint(
        rightPoint,
        controlPoint1: centerPoint,
        controlPoint2: rightControl)
    }else{
      let rightControl:CGPoint,leftControl:CGPoint,rightRightControl:CGPoint,leftLeftControl:CGPoint;
      switch edge{
      case .Top:
        centerPoint.y += (centerPoint.y - bounds.minY)/4
      case .Bottom:
        centerPoint.y += (centerPoint.y - bounds.maxY)/4
      case .Left:
        centerPoint.x += (centerPoint.x - bounds.minX)/4
      case .Right:
        centerPoint.x += (centerPoint.x - bounds.maxX)/4
      }
      switch edge{
      case .Top,.Bottom:
        rightControl = CGPointMake((rightPoint.x - centerPoint.x)*radiusFactor+centerPoint.x, (centerPoint.y + rightPoint.y)/2)
        leftControl = CGPointMake((centerPoint.x - leftPoint.x)*(1-radiusFactor)+leftPoint.x, (centerPoint.y + leftPoint.y)/2)
        // | --- (1 - 2*radiusFactor) --- leftLeftControl --- radiusFactor --- leftControl --- radiusFactor --- center --- ...
        
        rightRightControl = CGPointMake((rightPoint.x - centerPoint.x)*(2*radiusFactor)+centerPoint.x, (centerPoint.y > rightPoint.y ? min : max)(centerPoint.y,rightPoint.y))
        leftLeftControl = CGPointMake((centerPoint.x - leftPoint.x)*(1-2*radiusFactor)+leftPoint.x, (centerPoint.y > rightPoint.y ? min : max)(centerPoint.y,leftPoint.y))
      case .Left,.Right:
        rightControl = CGPointMake((centerPoint.x + rightPoint.x)/2, (rightPoint.y - centerPoint.y)*radiusFactor+centerPoint.y)
        leftControl = CGPointMake((centerPoint.x + leftPoint.x)/2, (centerPoint.y - leftPoint.y)*(1-radiusFactor)+leftPoint.y)
        
        rightRightControl = CGPointMake((centerPoint.x > rightPoint.x ? min : max)(centerPoint.x,rightPoint.x),(rightPoint.y - centerPoint.y)*(2*radiusFactor)+centerPoint.y)
        leftLeftControl = CGPointMake((centerPoint.x > rightPoint.x ? min : max)(centerPoint.x,leftPoint.x), (centerPoint.y - leftPoint.y)*(1-2*radiusFactor)+leftPoint.y)
      }
      
      shapePath.addCurveToPoint(
        leftControl,
        controlPoint1: leftPoint,
        controlPoint2: leftLeftControl)
      
      shapePath.addCurveToPoint(
        rightControl,
        controlPoint1: leftControl,
        controlPoint2: centerPoint)
      
      shapePath.addCurveToPoint(
        rightPoint,
        controlPoint1: rightControl,
        controlPoint2: rightRightControl)
      
    }
    
    shapePath.addLineToPoint(bottomRightPoint)
    shapePath.addLineToPoint(bottomLeftPoint)
    shapePath.addLineToPoint(leftPoint)
    shapePath.closePath()
    
    return shapePath.CGPath
  }
}
