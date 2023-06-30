import XCTest
@testable import MyObservation

@MyObservable final class Person {
    var name: String = "Tom"
    var age: Int = 25
}

let sample = Person()
let sample1 = Person()

final class MyObservationTests: XCTestCase {
    func testBackingStorage() throws {
        XCTAssertEqual(sample._name, "Tom")
        XCTAssertEqual(sample._age, 25)
    }

    func testObservation() throws {
        var numberOfCalls = 0
        withObservationTracking {
            _ = sample.name
        } onChange: {
            numberOfCalls += 1
        }
        XCTAssertEqual(numberOfCalls, 0)
        sample.age += 1
        XCTAssertEqual(numberOfCalls, 0)
        sample.name.append("!")
        XCTAssertEqual(numberOfCalls, 1)
        sample.name.append("!")
        XCTAssertEqual(numberOfCalls, 1)
    }

    func testObservationMultipleObjects() throws {
        var numberOfCalls = 0
        withObservationTracking {
            _ = sample.name
            _ = sample1.name
        } onChange: {
            numberOfCalls += 1
        }
        sample.name.append("!")
        XCTAssertEqual(numberOfCalls, 1)
        sample1.name.append("!")
        XCTAssertEqual(numberOfCalls, 1)
    }
}
