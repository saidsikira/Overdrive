# Overdrive
Task based API in Swift with focus on type-safety, concurrency, threading and stability.

[![Build Status](https://travis-ci.org/arikis/Overdrive.svg?branch=master)](https://travis-ci.org/arikis/Overdrive)
![Plaforms](https://img.shields.io/badge/platform-linux | iOS | macOS | tvOS-lightgray.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-Compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

**Contents:**

* [what can I do with Overdrive?](#what-can-i-do-with-overdrive)
* [requirements](#requirements)
* [usage](#usage)
* [concurrency](#concurrency)
* [thread safety](#thread-safety)
* [inspiration](#inspiration)

## what can I do with Overdrive?

* execute tasks concurrently 
* utilize multi-core capabilities to ensure faster execution
* easily defer task execution to custom thread or queue
* ensure that multiple tasks are executed in the correct order
* express custom conditions under which tasks can be executed
* enforce testability
* move logic from view controllers to simple modular units
* retry tasks that finished with errors
* don’t worry about thread-safety

## requirements

- iOS 8.0+ / Mac OS X 10.11+ / tvOS 9.0+ 
- Xcode 7.3+
- Swift 2.2 on Linux

## installation

#### [Carthage](https://github.com/Carthage/Carthage)
Add following to the `Cartfile`:

```shell
github "arikis/Overdrive" >= 0.0.1
```

#### [Cocoa Pods](https://github.com/CocoaPods/CocoaPods)

```ruby
platform :ios, '8.0'
use_frameworks!

target 'AppTarget' do
    pod 'Overdrive'
end
```

#### [Swift Package Manager](https://github.com/apple/swift-package-manager)

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

## usage

Overdrive features two main classes:

- `Task<T>` - used to define task [documentation](https://arikis.github.io/Overdrive/latest/Classes/Task.html)
- `TaskQueue` - used to execute tasks and manage concurrency and multi threading [documentation](https://arikis.github.io/Overdrive/latest/Classes/TaskQueue.html)

**Workflow:**

1. Create subclass of `Task<T>`
2. Override `run()` method and encapsulate any synchronous or asynchronous operation
3. Finish execution with value(`T`) or error by using `finish(_:)` method
4. Create instance of subclass
5. Add it to the `TaskQueue` when you want to start execution

Example `Task<NSData>` subclass for network operation:

```swift
// Create subclass of `Task<NSData>`
class NetworkTask: Task<NSData> {
	let URL: NSURL

	init(URL: NSURL) {
	    self.URL = URL
	}

	// Override run() method
	override func run() {
	    let request = NSURLRequest(URL: URL)
	    
	    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
	        data, response, error in
	        if error != nil {
	        	// Finish with error if any
	            self.finish(.Error(error!))
	        } else {
	        	// Finish with value
	            self.finish(.Value(data!))
	        }
	    }
	    
	    task.resume()
	}
}
```

To setup completion blocks, you use `onValue()` and `onError()` methods:

```swift
let task = NetworkTask(URL: NSURL(string: "https://google.com")!)

task
    .onValue { data in
    	print(data)
    }.onError { error in
        print(error)
}
```

To execute the task add it to the `TaskQueue`

```swift
let queue = TaskQueue()
queue.addTask(task)
```

## concurrency

`TaskQueue` executes tasks concurrently by default. Maximum number of concurrent
operations is defined by the current system conditions. If you want to limit the
number of maximum concurrent operations use `maxConcurrentOperationCount` property.

```swift
let queue = TaskQueue()
queue.maxConcurrentOperationCount = 3
```

## thread safety

All task properties are thread-safe by default, meaning that you can access them
from any thread or queue and not worry about locks and access synchronization.

## inspiration

Inspiration for the `Overdrive` framework came from several WWDC videos:

* [Protocol Oriented Programming](https://developer.apple.com/videos/play/wwdc2015/408/)
* [Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/)
* [Protocol and Value Oriented Programming](https://developer.apple.com/videos/play/wwdc2016/419/)

> `Overdrive` name comes from overdrive guitar pedals that drive amp tubes and create
louder, distorted sound
