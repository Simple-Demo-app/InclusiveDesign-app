import XCTest
@testable import App

final class AppTests: XCTestCase {
    func testAppInfo() {
        XCTAssertEqual("Inclusive Design", App.title)
        let _ = App().body
    }
}
