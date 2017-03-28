<img src="http://i.imgur.com/pp7QHRW.png" width="40%" height="40%"/>

[![Build Status](https://travis-ci.org/arikis/Overdrive.svg?branch=master)](https://travis-ci.org/arikis/Overdrive)
[![Plaforms](https://img.shields.io/badge/platform-%20iOS%20|%20macOS%20|%20tvOS%20|%20linux-gray.svg)](https://img.shields.io/badge/platform-%20iOS%20|%20macOS%20|%20tvOS%20|%20linux-gray.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

Our apps constantly do work. The faster you react to user input and produce an output, the more likely is that the user will continue to use your application. As our applications grow in complexity, the more and more work needs to be done. You need to start thinking about how to categorize and optimize work, how to make that work more efficient, more optimized and finally, faster. In most cases that doesn’t end very well because you need to know a lot about concurrency, multithreading etc. - it’s a very complex field. You need to know all API specifics before you are able to write something.

Overdrive was created as a result of that struggle. It is a framework that exposes several simple concepts which are made on top of complex system frameworks that enable multithreading, concurrency and most importantly, more speed.

```swift
let task = URLSessionTask("https://api.swiftable.io")

task
  .retry(3)
  .onValue { json in
    print(json["message"])
  }.onError { error in
    print(error)
  }

TaskQueue.background.add(task: task)
```

### Contents:

* [What can I do with Overdrive?](#what-can-i-do-with-overdrive)
* [Requirements](#requirements)
* [Usage](#usage)
* [Concurrency](#concurrency)
* [Thread safety](#thread-safety)
* [Inspiration](#inspiration)
* [Documentation](https://arikis.github.io/Overdrive/latest/)
  * [Getting Started](https://arikis.github.io/Overdrive/latest/getting-started.html)
  * [Installation](https://arikis.github.io/Overdrive/latest/installation.html)
  * [Complex tasks](https://arikis.github.io/Overdrive/latest/complex-tasks.html)
  * [State Machine](https://arikis.github.io/Overdrive/latest/state-machine.html)
  * [Unit Testing](https://arikis.github.io/Overdrive/latest/unit-testing.html)
* [Long term plans](#long-term-plans)

## What can I do with Overdrive?

- [x] Execute tasks concurrently
- [x] Utilize multi-core systems by default
- [x] Easily defer task execution to custom thread or queue
- [x] Ensure that multiple tasks are executed in the correct order
- [x] Express custom conditions under which tasks can be executed
- [x] Enforce testability
- [x] Retry tasks that finished with errors
- [x] Write thread safe code by default

## Requirements

- Xcode `8.0+`
- Swift 3
- Platforms:
  * iOS `8.0+`
  * macOS `10.11+`
  * tvOS `9.0+`
  * watchOS `2.0+`
  * Ubuntu

## Installation

#### [Carthage](https://github.com/Carthage/Carthage)

```shell
github "arikis/Overdrive" >= 0.2
```

#### [Cocoa Pods](https://github.com/CocoaPods/CocoaPods)

```ruby
platform :ios, '8.0'
use_frameworks!

target 'Your App Target' do
    pod 'Overdrive', '~> 0.2'
end
```

#### [Swift Package Manager](https://github.com/apple/swift-package-manager)

```swift
import PackageDescription

let package = Package(
  name: "Your Package Name",
  dependencies: [
    .Package(url: "https://github.com/arikis/Overdrive.git",
            majorVersion: 0,
            minor: 2)
  ]
)
```

#### Manual installation
`Overdrive` can also be installed manually by dragging the `Overdrive.xcodeproj` to your project and adding `Overdrive.framework` to the embedded libraries in project settings.

## Usage

Overdrive features two main classes:

- [`Task<T>`](https://github.com/arikis/Overdrive/blob/docs/Sources/Overdrive/Task.swift) - Used to encapsulate any asynchronous or synchronous work - [Documentation](https://arikis.github.io/Overdrive/latest/Classes/Task.html)
- [`TaskQueue`](https://github.com/arikis/Overdrive/blob/docs/Sources/Overdrive/TaskQueue.swift) - Used to execute tasks and manage concurrency and multi threading -  [Documentation](https://arikis.github.io/Overdrive/latest/Classes/TaskQueue.html)

**Workflow:**

1. Create subclass of `Task<T>`
2. Override `run()` method and encapsulate any synchronous or asynchronous operation
3. Finish execution with `value(T)` or `error(Error)` by using `finish(with:)` method
4. Create instance of subclass
5. Add it to the `TaskQueue` when you want to start execution

Example `Task<UIImage>` subclass for photo download task:

```swift
class GetLogoTask: Task<UIImage> {

  override func run() {
      let logoURL = URL(string: "https://swiftable.io/logo.png")!

      do {
          let logoData = try Data(contentsOf: logoURL)
          let image = UIImage(data: logoData)!
          finish(with: .value(image)) // finish with image
      } catch {
          finish(with: .error(error)) // finish with error if any
      }
  }
}
```

To setup completion blocks, you use `onValue` and `onError` methods:

```swift
let logoTask = GetLogoTask()

logoTask
    .onValue { logo in
        print(logo) // UIImage object
    }.onError { error in
        print(error)
}
```

To execute the task add it to the instance of `TaskQueue`

```swift
let queue = TaskQueue()
queue.add(task: logoTask)
```

## Concurrency

`TaskQueue` executes tasks concurrently by default. Maximum number of concurrent operations is defined by the current system conditions. If you want to limit the number of maximum concurrent task executions use `maxConcurrentTaskCount` property.

```swift
let queue = TaskQueue()
queue.maxConcurrentTaskCount = 3
```

## Thread safety

All task properties are thread-safe by default, meaning that you can access them from any thread or queue and not worry about locks and access synchronization.

## Inspiration

`Overdrive` framework was heavily inspired by talks and code from several Apple WWDC videos.

* [Protocol Oriented Programming](https://developer.apple.com/videos/play/wwdc2015/408/)
* [Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/)
* [Protocol and Value Oriented Programming](https://developer.apple.com/videos/play/wwdc2016/419/)

> `Overdrive` is a term for an effect used in electric guitar playing that occurs when guitar amp tubes starts to produce overdriven, almost distorted sound, due to the higher gain(master) setting.

## Long term plans

This section defines some long term plans for Overdrive. They're not scheduled for implementation or for any specific version.

#### Remove `Foundation.Operation` dependency

Currently, Overdrive leverages `Foundation.Operation` and `Foundation.OperationQueue` classes for concurrency and execution. While those classes provide excellent functionality, they're still rewrites of their Objective C counterpart (`NSOperation` and `NSOperationQueue`). This means that writing `Task<T>` requires a lot of overrides and state management.

For example, any task subclass must override `run()` method to define execution point. If this method is not overridden, queue will perform assert to notify that this method should be overridden. Same will happen if `super.run()` is called.

In the future, Overdrive should only use `libdispatch` for it's functionality.
