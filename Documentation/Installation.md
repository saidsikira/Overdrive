# Installation

You can use Overdrive in your projects by using one of the following package managers:

* [Carthage](#carthage)
* [CocoaPods](#cocoapods)
* [Swift Package Manager](#swift-package-manager)
* [Manual integration](#manual-integration)

## Carthage

[Carthage](#https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Overdrive with Carthage add following to your `Cartfile`:

```
github "arikis/Overdrive" >= 0.0.2
```

Then download and build Overdrive by running:

```shell
$ carthage update
```

Carthage will build a version of framework for each Apple platform (iOS, macOS, tvOS and watchOS) in `Carthage/Builds` folder.

> More information on integrating frameworks with Carthage can be found [here](#https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

## CocoaPods

CocoaPods is a longstanding dependency manager in any Cocoa development. To use Overdrive with CocoaPods add following to your `Podfile`

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Your Target Name' do
    pod 'Overdrive', '~> 0.0.2'
end
```

# Swift Package Manager

Swift Package Manager is the official package manager for distributing Swift code. Currently, it only supports building for macOS and Linux. To build and integrate Overdrive with Swift PM, add it to your `Package.swift` file.

```swift
import PackageDescription

let package = Package(
  name: "Your Package Name",
  dependencies: [
    .Package(url: "https://github.com/arikis/Overdrive.git",
            majorVersion: 0,
            minorVersion: 2)
  ]
)
```

## Manual integration

Overdrive can also be installed without any dependency manager by adding it to the project directly.

* If you are **using git**, you can add Overdrive as a submodule inside your project root folder:

```shell
git submodule add https://github.com/arikis/Overdrive.git
```

* If you are not using git, you can simply download Overdrive by clicking [here](#https://github.com/arikis/Overdrive/archive/master.zip). Then, extract the downloaded archive and move everything inside Overdrive folder that you can create in your project root folder.

* Locate `Ovedrive.xcodeproj` file inside your `Overdrive` folder and drag it to your project tree in Xcode.

* Click on your project in Xcode, click on the **General** tab and scroll until you find **Embedded libraries and frameworks** section. Click on the plus button and select `Overdrive.framework`. Overdrive can now be used simply by importing it normally in your application.
