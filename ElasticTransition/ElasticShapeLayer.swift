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
  public var edge:Edge = .bottom{
    didSet{
      path = currentPath()
    }
  }
  public var dragPoint:CGPoint = CGPoint.zero{
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
    
    backgroundColor = UIColor.clear.cgColor
    fillColor = UIColor.black.cgColor
    actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull(), "fillColor" : NSNull()]
  }
  override public init(layer: Any) {
    super.init(layer: layer)
  }

  required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  private func currentPath() -> CGPath {
    var centerPoint = dragPoint
    
    let leftPoint:CGPoint,rightPoint:CGPoint,bottomRightPoint:CGPoint,bottomLeftPoint:CGPoint
    switch edge{
    case .top:
      leftPoint = CGPoint(x: 0 - max(0,bounds.width/2 - dragPoint.x), y: bounds.minY)
      rightPoint = CGPoint(x: bounds.width + max(0,dragPoint.x-bounds.width/2), y: bounds.minY)
      bottomRightPoint = CGPoint(x: bounds.maxX, y: bounds.maxY)
      bottomLeftPoint = CGPoint(x: bounds.minX, y: bounds.maxY)
    case .bottom:
      leftPoint = CGPoint(x: bounds.width + max(0,dragPoint.x-bounds.width/2), y: bounds.maxY)
      rightPoint = CGPoint(x: 0 - max(0,bounds.width/2 - dragPoint.x), y: bounds.maxY)
      bottomRightPoint = CGPoint(x: bounds.minX, y: bounds.minY)
      bottomLeftPoint = CGPoint(x: bounds.maxX, y: bounds.minY)
    case .left:
      leftPoint = CGPoint(x: bounds.minX, y: bounds.height + max(0,dragPoint.y-bounds.height/2))
      rightPoint = CGPoint(x: bounds.minX, y: 0 - max(0,bounds.height/2 - dragPoint.y))
      bottomRightPoint = CGPoint(x: bounds.maxX, y: bounds.minY)
      bottomLeftPoint = CGPoint(x: bounds.maxX, y: bounds.maxY)
    case .right:
      leftPoint = CGPoint(x: bounds.maxX, y: 0 - max(0,bounds.height/2 - dragPoint.y))
      rightPoint = CGPoint(x: bounds.maxX, y: bounds.height + max(0,dragPoint.y-bounds.height/2))
      bottomRightPoint = CGPoint(x: bounds.minX, y: bounds.maxY)
      bottomLeftPoint = CGPoint(x: bounds.minX, y: bounds.minY)
    }
    
    let shapePath = UIBezierPath()
    shapePath.move(to: leftPoint)
    
    if radiusFactor>=0.5{
      let rightControl:CGPoint,leftControl:CGPoint;
      switch edge{
      case .top,.bottom:
        rightControl = CGPoint(x: (rightPoint.x - centerPoint.x)*0.8+centerPoint.x, y: centerPoint.y)
        leftControl = CGPoint(x: (centerPoint.x - leftPoint.x)*0.2+leftPoint.x, y: centerPoint.y)
      case .left,.right:
        rightControl = CGPoint(x: centerPoint.x, y: (rightPoint.y - centerPoint.y)*0.8+centerPoint.y)
        leftControl = CGPoint(x: centerPoint.x, y: (centerPoint.y - leftPoint.y)*0.2+leftPoint.y)
      }
      
      shapePath.addCurve(
        to: centerPoint,
        controlPoint1: leftPoint,
        controlPoint2: leftControl)
      
      shapePath.addCurve(
        to: rightPoint,
        controlPoint1: centerPoint,
        controlPoint2: rightControl)
    }else{
      let rightControl:CGPoint,leftControl:CGPoint,rightRightControl:CGPoint,leftLeftControl:CGPoint;
      switch edge{
      case .top:
        centerPoint.y += (centerPoint.y - bounds.minY)/4
      case .bottom:
        centerPoint.y += (centerPoint.y - bounds.maxY)/4
      case .left:
        centerPoint.x += (centerPoint.x - bounds.minX)/4
      case .right:
        centerPoint.x += (centerPoint.x - bounds.maxX)/4
      }
      switch edge{
      case .top,.bottom:
        rightControl = CGPoint(x: (rightPoint.x - centerPoint.x)*radiusFactor+centerPoint.x, y: (centerPoint.y + rightPoint.y)/2)
        leftControl = CGPoint(x: (centerPoint.x - leftPoint.x)*(1-radiusFactor)+leftPoint.x, y: (centerPoint.y + leftPoint.y)/2)
        // | --- (1 - 2*radiusFactor) --- leftLeftControl --- radiusFactor --- leftControl --- radiusFactor --- center --- ...
        
        rightRightControl = CGPoint(x: (rightPoint.x - centerPoint.x)*(2*radiusFactor)+centerPoint.x, y: (centerPoint.y > rightPoint.y ? min : max)(centerPoint.y,rightPoint.y))
        
        let a = (centerPoint.x - leftPoint.x)
        let b = (1-2*radiusFactor)+leftPoint.x
        
        leftLeftControl = CGPoint(x: a*b, y: (centerPoint.y > rightPoint.y ? min : max)(centerPoint.y,leftPoint.y))
      case .left,.right:
        rightControl = CGPoint(x: (centerPoint.x + rightPoint.x)/2, y: (rightPoint.y - centerPoint.y)*radiusFactor+centerPoint.y)
        leftControl = CGPoint(x: (centerPoint.x + leftPoint.x)/2, y: (centerPoint.y - leftPoint.y)*(1-radiusFactor)+leftPoint.y)
        
        rightRightControl = CGPoint(x: (centerPoint.x > rightPoint.x ? min : max)(centerPoint.x,rightPoint.x),y: (rightPoint.y - centerPoint.y)*(2*radiusFactor)+centerPoint.y)
        leftLeftControl = CGPoint(x: (centerPoint.x > rightPoint.x ? min : max)(centerPoint.x,leftPoint.x), y: (centerPoint.y - leftPoint.y)*(1-2*radiusFactor)+leftPoint.y)
      }
      
      shapePath.addCurve(
        to: leftControl,
        controlPoint1: leftPoint,
        controlPoint2: leftLeftControl)
      
      shapePath.addCurve(
        to: rightControl,
        controlPoint1: leftControl,
        controlPoint2: centerPoint)
      
      shapePath.addCurve(
        to: rightPoint,
        controlPoint1: rightControl,
        controlPoint2: rightRightControl)
      
    }
    
    shapePath.addLine(to: bottomRightPoint)
    shapePath.addLine(to: bottomLeftPoint)
    shapePath.addLine(to: leftPoint)
    shapePath.close()
    
    return shapePath.cgPath
  }
}
