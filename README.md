# SABlurImageView

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![Version](https://img.shields.io/cocoapods/v/SABlurImageView.svg?style=flat)](http://cocoapods.org/pods/SABlurImageView)
[![License](https://img.shields.io/cocoapods/l/SABlurImageView.svg?style=flat)](http://cocoapods.org/pods/SABlurImageView)

![](./SampleImage/sample.gif)

You can use blur effect and it's animation easily to call only two methods.

[ManiacDev.com](https://maniacdev.com/) referred.  
[https://maniacdev.com/2015/04/open-source-ios-library-for-easily-adding-animated-blurunblur-effects-to-an-image](https://maniacdev.com/2015/04/open-source-ios-library-for-easily-adding-animated-blurunblur-effects-to-an-image)

## Features

- [x] Blur effect with box size
- [x] Blur animation
- [x] 0.0 to 1.0 parameter blur
- [x] Support Swift2.0

## Installation

#### CocoaPods

SABlurImageView is available through [CocoaPods](http://cocoapods.org). If you have cocoapods 0.38.0 or greater, you can install
it, simply add the following line to your Podfile:

    pod "SABlurImageView"

#### Manually

Add the [SABlurImageView](./SABlurImageView) directory to your project.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

If you install from pod, you have to write `import SABlurImageView`.

If you want to apply blur effect for image

```swift
	let imageView = SABlurImageView(image: image)
	imageView.addBlurEffect(30, times: 1)
```

If you want to animate

```swift
	let imageView = SABlurImageView(image: image)
	imageView.configrationForBlurAnimation()
	imageView.startBlurAnimation(duration: 2.0)
```

First time of blur animation is normal to blur. Second time is blur to normal. (automatically set configration of reverse animation)

If you want to use 0.0 to 1.0 parameter

```swift
	let imageView = SABlurImageView(image: image)
	imageView.configrationForBlurAnimation(100)
	imageView?.blur(0.5)
```

## Installation

SABlurImageView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SABlurImageView"
```
## Requirements

- Xcode 7.0 or greater
- iOS7.0(manually only) or greater
- QuartzCore
- Accelerate

## Change Log

### v2.0.0 -> v2.1.0

Use `CGFloat`, instead of `Float`

## Author

Taiki Suzuki, s1180183@gmail.com

## Other

Objective-C version of this project is [SABlurImageViewObjc](https://github.com/szk-atmosphere/SABlurImageViewObjc).

## License

SABlurImageView is available under the MIT license. See the LICENSE file for more info.
