# ElasticTransition

[![Version](https://img.shields.io/cocoapods/v/ElasticTransition.svg?style=flat)](http://cocoapods.org/pods/ElasticTransition)
[![License](https://img.shields.io/cocoapods/l/ElasticTransition.svg?style=flat)](http://cocoapods.org/pods/ElasticTransition)
[![Platform](https://img.shields.io/cocoapods/p/ElasticTransition.svg?style=flat)](http://cocoapods.org/pods/ElasticTransition)

A UIKit custom modal transition that simulates an elastic drag. Written in Swift.

![demo](https://github.com/lkzhao/ElasticTransition/blob/master/demo.gif?raw=true)

## Requirements

* Xcode 7 or higher
* iOS 7.0 or higher
* ARC
* Swift 2.0

## Installation

####CocoaPods

*iOS 8 or later*

```ruby
use_frameworks!
pod "ElasticTransition"
```

####Manual

[Download](https://github.com/lkzhao/ElasticTransition/archive/master.zip) and add ElasticTransition folder into your project.

## Usage

##### 1. In your view controller, do the following
```swift
var transition = ElasticTransition()
override func viewDidLoad() {
  super.viewDidLoad()

  // this setup the pan gesturerecognizer & transition delegate
  transition.backViewController = self

  // this tells the transition which segue to trigger when drag start
  transition.segueIdentifier = "menu"

  // customization
  transition.edge = .Left
  transition.sticky = false
  transition.panThreshold = 0.3
  transition.fancyTransform = false
  // ...
}

override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  transition.frontViewController = segue.destinationViewController
}
```

##### 2. Implement ElasticMenuTransitionDelegate in your modal view controller

```swift
protocol ElasticMenuTransitionDelegate{
  var contentView:UIView! {get}
}
```

You can do this either by using storyboard ( *IBOutlet* ) or programatically. See the example project.

##### Important **NOTE** for implementing ElasticMenuTransitionDelegate:
* contentView should be a subview of self.view
* contentView should be placed along the edge specified to the transition
* contentView should have a **clear** background color
* lastly, set self.view.backgroundColor to be the color you desire

## How does it work?
If you want to know the detail of the implementation, see it [here](https://github.com/lkzhao/ElasticTransition/blob/master/howdoesitwork.md)

## Todo
1. Better Guide and Documentation
2. Cleanup Interface
4. More settings to customize
5. Support navigation controller transition

## Author

Luke Zhao, me@lkzhao.com

## License

ElasticTransition is available under the MIT license. See the LICENSE file for more info.
