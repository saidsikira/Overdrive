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

## Installation

* [Swift Package Manager](https://github.com)
* [Carthage](https://github.com)
* [Cocoa Pods](https://github.com)
* [Manual Installation](https://github.com)

#### Swift Package Manager
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

#### Carthage
Add following to the `Cartfile`:
```
github "Swiftable/Overdrive"
```

#### Cocoa Pods
You can also use Cocoa Pods to install `Overdrive` by adding it to the `Podfile`
```ruby
platform :ios, '8.0'
use_frameworks!

target 'AppTarget' do
    pod 'Overdrive'
end
```
