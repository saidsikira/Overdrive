# Overdrive
Task based API in Swift with focus on type-safety, concurrency, threading and stability.

![Plaforms](https://img.shields.io/badge/platform-linux | iOS | macOS | tvOS-lightgray.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-Compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Features:
* Type-safety
* Concurrency
* Full threading capabilities
* Testability
* Full documentation

## Requirements

- iOS 8.0+ / Mac OS X 10.9+ / tvOS 9.0+ 
- Xcode 7.3+
- Swift 2.2 on Linux

## Installation
You can use `Overdrive` in your project by using any of the following methods:

#### Carthage
Add following to the `Cartfile`:
```
github "Swiftable/Overdrive" >= 0.0.1
```
> Note that if you want to build Overdrive on only one platform you can pass it to the carthage platform option.
For example `carthage update --platform iOS`

#### Cocoa Pods
To use `Overdrive` with Cocoa Pods add it to the `Podfile`
```ruby
platform :ios, '8.0'
use_frameworks!

target 'AppTarget' do
    pod 'Overdrive'
end
```

#### Swift Package Manager

**Requiers Swift 2.2**

To add `Overdrive` to your project using Swift Package Manager, add it to the package dependencies:
```swift
import PackageDescription

let package = Package(
  name: "ProjectName",
  targets: [],
  dependencies: [
    .Package(url: "https://github.com/Swiftable/Overdrive.git", versions: "0.0.1"..< Version.max)
  ]
)
```
Note that Swift Package Manager support is still experimental.
