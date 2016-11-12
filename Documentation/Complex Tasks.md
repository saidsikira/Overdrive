# Dealing with complex tasks

In most of the scenarios we encounter while we are developing applications, we tackle complexity. And the key to make complex behaviors work is to decouple things one from another so that they can be tested and debugged easily. That almost always comes with a price, especially if you are dealing with asynchronous tasks.

Task dependencies can be used to construct complex task graphs with exact ordering of execution. More importantly, task dependency are not tied to any specific queue. Dependencies are no different than any other tasks - they behave the same. Only difference is that when you add a dependency to a task, task will wait until dependency is executed and finished with work.

## Example

Imaging you are building application for displaying some photos from the internet. You need to download the photos, present them and cache them. You could build one monolith structure or class that does all this but you'll run into problems soon, most likely because you'll be dealing with loads of asynchronous methods and completion blocks that are hard to debug.

With Overdrive, you can simplify this process and even gain additional performance and speed.

In this case, you will have two main defined tasks:

1. Task that downloads a photo (`DownloadPhotoTask`)
2. Task that caches downloaded photo on the disk (`CachePhotoTask`)

`PresentPhotoTask` will be the main task that can be used by the user. By utilizing dependency model, we can add `DownloadPhotoTask`  as a dependency of the `CachePhotoTask`, and be sure that dependency will be executed first.

Let's say our photo is located at `https://swiftable.io/logo.png`. After you implement all three tasks you could create their instances like this:

```swift
let downloadPhotoTask = DownloadPhotoTask(url: "https://swiftable.io/logo.png")
let cachePhotoTask = CachePhotoTask()
```

Now, in order to add dependency to the `cachePhotoTask`, you use `add(dependency:)` method:

```swift
cachePhotoTask.add(dependency: downloadPhotoTask)
```

All, that's left now is to execute tasks on queues. We can use different queues for any task:

```swift
let downloadQueue = TaskQueue() // Downloading can happen on any queue
let cacheQueue = TaskQueue(qos: .background) // All caching should be done on background queue

// Execute tasks
downloadQueue.add(task: downloadPhotoTask)
cacheQueue.add(task: cachePhotoTask)
```

At this point, tasks will be executed in this order:

1. `downloadPhotoTask` is executed first
2. After successful execution of `downloadPhotoTask`, `cachePhotoTask` will be executed on the background queue.

## Conclusion

Task dependency model can be used to construct complex tasks graphs with very simple syntax in order to achieve better performance, testability and in the end, faster execution.
