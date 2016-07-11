# Overdrive
Task based API in Swift with focus on type-safety, concurrency, threading and stability.

[![Build Status](https://travis-ci.org/arikis/Overdrive.svg?branch=master)](https://travis-ci.org/arikis/Overdrive)
![Plaforms](https://img.shields.io/badge/platform-linux | iOS | macOS | tvOS-lightgray.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-Compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Features:
* Type-safety
* Concurrency
* Full threading capabilities
* Full documentation
* Extensive tests

## Requirements

- iOS 8.0+ / Mac OS X 10.11+ / tvOS 9.0+ 
- Xcode 7.3+
- Swift 2.2 on Linux

## Installation
You can use `Overdrive` in your project by using any of the following package managers.

#### Carthage
Add following to the `Cartfile`:

```shell
github "arikis/Overdrive" >= 0.0.1
```

#### Cocoa Pods

```ruby
platform :ios, '8.0'
use_frameworks!

target 'AppTarget' do
    pod 'Overdrive'
end
```

#### Swift Package Manager

```swift
import PackageDescription

let package = Package(
  name: "ProjectName",
  targets: [],
  dependencies: [
    .Package(url: "https://github.com/arikis/Overdrive.git", 
    versions: "0.0.1"..< Version.max)
  ]
)
```

> Swift Package Manager support is still experimental.

#### Manual installation
`Overdrive` can also be installed manualy by dragging the `Overdrive.xcodeproj` to your project and adding `Overdrive.framework` to the embedded libraries in project settings.

## Usage

Overdrive features two main classes:

### `Task<T>`
`Task<T>` is an abstract class that provides interface encapsuling any
 asynchronous or synchronous operation. Abstract nature of the `Task<T>` enforces
 you to create a subclass for any task you want to create. Subclassing `Task<T>`
 is simple operation. You are only required to override `run()` method that
 defines task execution point and call `finish(_:)` method to finish execution.
 In order to execute any task you need to add it to the `TaskQueue` which
 manages task execution, concurrency and threading mechanisms.

 **Example subclass for networking operation**

 ```swift
 class NetworkTask: Task<NSData> {
    let URL: NSURL
    
    init(URL: NSURL) {
        self.URL = URL
    }
    
    override func run() {
        let request = NSURLRequest(URL: URL)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                self.finish(.Error(error!))
            } else {
                self.finish(.Value(data!))
            }
        }
        
        task.resume()
    }
}
```

To setup completion blocks, you use `onComplete()` and `onError()` methods:

```swift
let task = NetworkTask(URL: NSURL(string: "https://google.com")!)

task
    .onComplete { data in
    	print(data)
    }.onError { error in
        print(error)
}
```
