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
pod "ElasticTransition", "~> 3.0.0"
```

####Manual

[Download(v2.0.1)](https://github.com/lkzhao/ElasticTransition/archive/2.0.1.zip) and add ElasticTransition folder into your project.

## Usage

### Simple

```swift
import ElasticTransition
// make your view controller a subclass of ElasticModalViewController
// present it as normal
class YourModalViewController:ElasticModalViewController{ 
  // ... 
}

class RootViewController:UIViewController{
  // ...
  @IBAction func modalBtnTouched(sender: AnyObject) {
    performSegueWithIdentifier("modalSegueIdentifier", sender: self)

    // or if you want to do customization ---------------------
    let modalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("modalViewControllerIdentifier") as! YourModalViewController
    // customization:
    modalViewController.modalTransition.edge = .Left
    modalViewController.modalTransition.radiusFactor = 0.3
    // ...

    presentViewController(modalViewController, animated: true, completion: nil)
  }
}
```

### Attributes you can set:
```swift
  // screen edge of the transition
  public var edge:Edge
  // animation stiffness - determines the speed of the animation
  public var stiffness:CGFloat = 0.2
  // animation damping - determines the bounciness of the animation 
  public var damping:CGFloat = 0.2
  // Background view transform
  public var transformType:ElasticTransitionBackgroundTransform = .TranslateMid
  // The curvature of the elastic edge.
  public var radiusFactor:CGFloat = 0.5
  /**
   Determines whether or not the view edge will stick to
   the initial position when dragged.
   **Only effective when doing a interactive transition**
   */
  public var sticky:Bool = true
  /**
   The initial position of the simulated drag when static animation is performed
   i.e. The static animation will behave like user is dragging from this point
   **Only effective when doing a static transition**
   */
  public var startingPoint:CGPoint?
  /**
   The background color of the container when doing the transition
   */
  public var containerColor:UIColor = UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 1.0)
  /**
   The color of the overlay when doing the transition
   */
  public var overlayColor:UIColor = UIColor(red: 152/255, green: 174/255, blue: 196/255, alpha: 0.5)
  /**
   Whether or not to display the shadow. Will decrease performance.
   */
  public var showShadow:Bool = false
  /**
   The shadow color of the container when doing the transition
   */
  public var shadowColor:UIColor = UIColor(red: 100/255, green: 122/255, blue: 144/255, alpha: 1.0)
  /**
   The shadow radius of the container when doing the transition
   */
  public var shadowRadius:CGFloat = 50
```


------------------------
## Advance Usage

This work with any view controller. 

In prepareForSegue, assign the transition to be the transitioningDelegate of the destinationViewController.
Also, dont forget to set the modalPresentationStyle to .Custom

```swift
var transition = ElasticTransition()
override func viewDidLoad() {
  super.viewDidLoad()

  // customization
  transition.edge = .Left 
  transition.sticky = false
  // etc
}
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  segue.destinationViewController.transitioningDelegate = transition
  segue.destinationViewController.modalPresentationStyle = .Custom
}
```

(Optional) In your modal view controller implement the ElasticMenuTransitionDelegate and provide the contentLength
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

## Author

Luke Zhao, me@lkzhao.com

## License

ElasticTransition is available under the MIT license. See the LICENSE file for more info.
