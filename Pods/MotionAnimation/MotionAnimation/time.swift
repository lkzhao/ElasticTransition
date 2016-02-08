import Foundation

extension Int {
    var second:  NSTimeInterval { return NSTimeInterval(self) }
    var seconds: NSTimeInterval { return NSTimeInterval(self) }
    var minute:  NSTimeInterval { return NSTimeInterval(self * 60) }
    var minutes: NSTimeInterval { return NSTimeInterval(self * 60) }
    var hour:    NSTimeInterval { return NSTimeInterval(self * 3600) }
    var hours:   NSTimeInterval { return NSTimeInterval(self * 3600) }
}

extension Double {
    var second:  NSTimeInterval { return self }
    var seconds: NSTimeInterval { return self }
    var minute:  NSTimeInterval { return self * 60 }
    var minutes: NSTimeInterval { return self * 60 }
    var hour:    NSTimeInterval { return self * 3600 }
    var hours:   NSTimeInterval { return self * 3600 }
}