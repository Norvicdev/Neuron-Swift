import XCTest
@testable import Neuron

final class NeuronTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Neuron().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
