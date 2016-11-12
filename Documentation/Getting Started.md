# Getting started

Our apps constantly do work. The faster you react to user input and produce an output, the more likely is that the user will continue to use your application. As our applications grow in complexity, the more and more work needs to be done. You need to start thinking about how to categorize and optimize work, how to make that work more efficient, more optimized and finally, faster. In most cases that doesn't end very well because you need to know a lot about concurrency, multithreading etc. - it's a very complex field. You need to know all API specifics before you are able to write something.

Overdrive was created as a result of that struggle. It is a framework that exposes several simple concepts which are made on top of complex system frameworks that enable multithreading, concurrency and most importantly, more speed.

This guide will walk you through some basic Overdrive concepts.

### Topics:

* [Tasks](#tasks)
  * [Example task](#example-task-subclass)
  * [Task configuration](#task-configuration)
* [Task queues](#queues)
* [Task execution](#task-execution)

## Tasks

Unit of work in Overdrive is called a **Task**. Any task is exposed as a `Task<T>` class that you create subclass of.

Inside a subclass, you override `run()` method that is used to execute any work (synchronous or asynchronous). That may be fetching data from the internet or retrieving user location.

To finish work in the task, you pass your task result to the `finish(with: )` method. This method takes `Result<T>` as an argument (`.value(T)` or an `.error(Error)`). By using `T`, you task results are bound to be type-safe. If you create a subclass of `Task<Int>`, you would be only able to finish operation with `.value(Int)` or an error.

### Example task subclass

Let's say we want to create an task for fetching logo from the internet. Logo is located [**here**](https://swiftable.io/logo.png). Since it's a logo image, we'll `UIImage` class to represent it.

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

### Task configuration

To configure a task, you must create an instance of it.

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
Tasks can also be retried if they finished with error. Just add `retry()` at the end of task configuration.

```swift
task.retry(3)
```

## Queues

Task queues are in charge of executing tasks in most efficient way. When you add a task to the queue, queue will evaluate task and wait for it to be ready for execution. Once the task is ready, queue will execute it. Execution starts with overridden `run()` method in your task subclass and ends with called `finish(with:)` method or by task cancellation.

All task queues are executing tasks in multithreaded environment depending on your hardware. For example, you may add 4 tasks to the task queue and task queue will execute them all four of them at the same time which is perfect for the execution speed.

Task queues are objects exposed as ([`TaskQueue`](https://arikis.github.io/Overdrive/latest/Classes/TaskQueue.html)) classes. Each task queue is internally backed up with `Foundation.DispatchQueue`, so that you get all benefits of GDC for free. To create a `TaskQueue` object, simply initialize it:

```swift
let taskQueue = TaskQueue()
```

If you want to run your tasks on the specific dispatch queue, you can initialize it with `queue` parameter.

```swift
let someDispatchQueue = DispatchQueue(name: "MyQueue")
let queue = TaskQueue(queue: someDispatchQueue)
```

If you want to assign specific Quality Of Service class, you can pass it to the init with `qos` parameter.

```swift
let queue = TaskQueue(qos: .background)
```

Or, you can use predefined queues which are associated with app main queue and the app background queue.

```swift
TaskQueue.main // Application UI main queue
TaskQueue.background // associated with Background queue
```

## Task execution

After the task is configured with the completion blocks, you can execute it by adding it to the `TaskQueue`.

```swift
let task = GetLogoTask()
let queue = TaskQueue()
queue.add(task: task)
```
