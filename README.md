# ElasticTransition

[![Version](https://img.shields.io/cocoapods/v/ElasticTransition.svg?style=flat)](http://cocoapods.org/pods/ElasticTransition)
[![License](https://img.shields.io/cocoapods/l/ElasticTransition.svg?style=flat)](http://cocoapods.org/pods/ElasticTransition)
[![Platform](https://img.shields.io/cocoapods/p/ElasticTransition.svg?style=flat)](http://cocoapods.org/pods/ElasticTransition)

A UIKit custom modal transition that simulates an elastic drag. Written in Swift.

![demo](https://github.com/lkzhao/ElasticTransition/blob/master/imgs/demo.gif?raw=true)

###Special thanks to [@taglia3](https://github.com/taglia3) for developing the [Objective-C version] (https://github.com/taglia3/ElasticTransition-ObjC). Check it out!

## Requirements

* Xcode 7 or higher
* iOS 8.0 or higher
* ARC
* Swift 2.0

## Installation

####CocoaPods

```ruby
use_frameworks!
pod "ElasticTransition"
```

####Manual

[Download(v2.0.1)](https://github.com/lkzhao/ElasticTransition/archive/2.0.1.zip) and add ElasticTransition folder into your project.

## Usage

First of all, in your view controller, create an instance of ElasticTransition

```swift
var transition = ElasticTransition()
override func viewDidLoad() {
  super.viewDidLoad()

  // customization
  transition.edge = .Left
  transition.sticky = false
  transition.panThreshold = 0.3
  transition.transformType = .TranslateMid
  // ...
}
```

- [Navigation Controller Delegate](#use-as-navigation-controllers-delegate)
- [Modal](#present-as-modal)
  - [Interactive Present](#interactive-transition-for-modal-transition)
  - [Interactive Dismiss](#interactive-transition-for-dismissing-the-modal)

------------------------

#### Use as navigation controller's delegate

Simply assign the transition to your navigation controller's delegate

```swift
navigationController?.delegate =transition
```

------------------------

#### Present as modal

In prepareForSegue, assign the transition to be the transitioningDelegate of the destinationViewController.
Also, dont forget to set the modalPresentationStyle to .Custom

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  segue.destinationViewController.transitioningDelegate = transition
  segue.destinationViewController.modalPresentationStyle = .Custom
}
```

In your modal view controller implement the ElasticMenuTransitionDelegate and provide the contentLength
```swift
class MenuViewController: UIViewController, ElasticMenuTransitionDelegate {
  var contentLength:CGFloat = 320
  // ...
}
```

##### Interactive transition for modal transition

First, construct a pan gesture recognizer

```swift
let panGR = UIPanGestureRecognizer(target: self, action: "handlePan:")
view.addGestureRecognizer(panGR)
```

Then implement your gesture handler and fo the following:

```swift
func handlePan(pan:UIPanGestureRecognizer){
  if pan.state == .Began{
    // Here, you can do one of two things
    // 1. show a viewcontroller directly
    let nextViewController = // construct your VC ...
    transition.startInteractiveTransition(self, toViewController: nextViewController, gestureRecognizer: pan)
    // 2. perform a segue
    transition.startInteractiveTransition(self, segueIdentifier: "menu", gestureRecognizer: pan)
  }else{
    transition.updateInteractiveTransition(gestureRecognizer: pan)
  }
}
```

##### Interactive transition for dismissing the modal

1. Implement ElasticMenuTransitionDelegate in your modal view controller and set

```swift
  var dismissByBackgroundTouch = true
  var dismissByBackgroundDrag = true
  var dismissByForegroundDrag = true
```

2. Or use your own panGestureRecognizer and call dissmissInteractiveTransition in your handler
```swift
func handlePan(pan:UIPanGestureRecognizer){
  if pan.state == .Began{
    transition.dissmissInteractiveTransition(self, gestureRecognizer: pan, completion: nil)
  }else{
    transition.updateInteractiveTransition(gestureRecognizer: pan)
  }
}
```

## Todo
1. Better Guide and Documentation
2. Testing

## Author

Luke Zhao, me@lkzhao.com

## License

ElasticTransition is available under the MIT license. See the LICENSE file for more info.
