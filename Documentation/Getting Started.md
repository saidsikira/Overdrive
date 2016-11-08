# Getting started

Our apps constantly do work. The faster you react so some input and produce an output, the more likely is that the user will continue to use your application. As our applications grow in complexity, the more and more work needs to be done. You need to start thinking about how to categorize and optimize work, how to make work more efficient, how to offload work, consider multithreading etc. In most cases that doesn't end very well because it's a very complex field. You need to know all API specifics before you are able to write something.

Overdrive was created as a result of that struggle. It is a framework that exposes several simple concepts which are made on top of complex system frameworks that enable multithreading, concurrency and most importantly, more speed.

## Tasks and queues

Unit of work in Overdrive is called a **Task**. Any task is exposed as a `Task<T>` class that you create subclass of. Inside a subclass, you override `run()` method that is used to execute your work. That may be fetching data from the internet or retrieving user location.

To finish work in the task, you call `finish(with: )` method. This method can take a `.value(T)` or an `.error(Error)`. This means that your tasks are type safe. If you create a subclass of `Task<Int>`, you would be only able to finish operation with `.value(Int)` or an error.

To execute a task, you create an instance of it and you add it to the task queue. `TaskQueue` will then execute your tasks concurrently and in the most efficient way by default.

## Example task

Let's say we want to create an task for fetching logo photo from the internet. Logo is located [here](https://swiftable.io/logo.png) and we want to fetch the photo and return it as an `UIImage` instance.


```swift
class GetLogoTask: Task<UIImage> {

  override func run() {
      let logoURL = URL(string: "https://swiftable.io/logo.png")!

      do {
          let logoData = try Data(contentsOf: logoURL)
          let image = UIImage(data: logoData)!
          finish(with: .value(image))
      } catch {
          finish(with: .error(error))
      }
  }
}
```

1. Created subclass of `Task<UIImage>`
2. Override run method
3. Fetch the raw data using `Data(contentsOf:)` method
4. Create `UIImage` object from the returned `Data`
5. Finish with `.value(image)` if everything went well
6. Finish with `.error` is error was thrown

## Configuring task

To execute task, you must create an instance of it.

```swift
let task = GetLogoTask()
```

Tasks can provide information about the finish result. You can use `onValue:` and `onError:` methods to define what happens when task finishes.

```swift
task
  .onValue { image in
    print(image) // UIImage object
  }.onError { error in
    print(error)
  }
```

## Task execution

After the task is configured with the completion blocks, you can execute it by adding it to the `TaskQueue` object. `TaskQueue` queue objects can be created manually or you can use preconfigured ones. Let's say that we want to execute this task in the background queue.

```swift
TaskQueue.background.add(task: task)
```
