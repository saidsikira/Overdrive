# Unit testing with Overdrive

Unit testing for any task is very simple since you have only two possible execution results: `.value(T)` or `error(Error)`. Important thing to note is that you will have to use test expectations (`XCTestExpectation`) since task execution may be asynchronous.

### Example test case

```swift
public class TaskTests: XCTestCase {

  func testGetLogoTask() {
    let expecation = expecation(description: "Get logo task result expectation")

    let logoTask = GetLogoTask(url: "https://swiftable.io")

    logoTask
      .onValue { logo in
        expecation.fulfill()
      }.onError { error in
        XCTFail("Fail with error \(error)")
      }

    let queue = TaskQueue()
    queue.add(task: logoTask)

    waitForExpectations(timeout: 1) { _ in }
  }
}
