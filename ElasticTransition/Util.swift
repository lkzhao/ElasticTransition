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

let π:CGFloat = CGFloat(M_PI)

public enum Edge{
    case Top, Bottom, Left, Right
    public func opposite() -> Edge{
        switch self {
        case .Left:
            return .Right
        case .Right:
            return .Left
        case .Bottom:
            return .Top
        case .Top:
            return .Bottom
        }
    }
    public func toUIRectEdge() -> UIRectEdge{
        switch self {
        case .Left:
            return .Left
        case .Right:
            return .Right
        case .Bottom:
            return .Bottom
        case .Top:
            return .Top
        }
    }
}

extension CGPoint{
    func transform(t:CGAffineTransform) -> CGPoint{
        return CGPointApplyAffineTransform(self, t)
    }
    
    func distance(b:CGPoint)->CGFloat{
        return sqrt(pow(self.x-b.x,2)+pow(self.y-b.y,2));
    }
}

class DynamicItem:NSObject, UIDynamicItem{
    var center: CGPoint = CGPointZero
    var bounds: CGRect = CGRectMake(0, 0, 1, 1)
    var transform: CGAffineTransform = CGAffineTransformIdentity
    init(center:CGPoint) {
        self.center = center
        super.init()
    }
}

class CustomSnapBehavior:UIDynamicBehavior {
    var attachmentBehavior:UIAttachmentBehavior?
    var snapBehavoir:UISnapBehavior?
    
    var length:CGFloat = 0{
        didSet{
            if let ab = attachmentBehavior{
                ab.length = length
            }
        }
    }
    var frequency:CGFloat = 1{
        didSet{
            if let ab = attachmentBehavior{
                ab.frequency = frequency
            }
        }
    }
    var damping:CGFloat = 0{
        didSet{
            if let ab = attachmentBehavior{
                ab.damping = damping
            }else{
                snapBehavoir!.damping = damping
            }
        }
    }
    var point:CGPoint{
        didSet{
            if let ab = attachmentBehavior{
                ab.anchorPoint = point
            }else{
                snapBehavoir!.snapPoint = point
            }
        }
    }
    init(item:UIDynamicItem, point:CGPoint, useSnap:Bool = false) {
        self.point = point
        super.init()
        if useSnap{
            snapBehavoir = UISnapBehavior(item: item, snapToPoint: point)
            addChildBehavior(snapBehavoir!)
        }else{
            attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: point)
            addChildBehavior(attachmentBehavior!)
        }
    }
}
