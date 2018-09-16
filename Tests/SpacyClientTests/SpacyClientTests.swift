import XCTest
@testable import SpacyClient

final class SpacyClientTests: XCTestCase {

    func testClient() throws {
        let expectiation = self.expectation(description: "completion is called")

        let client = SpacyClient(baseURL: URL(string: "http://localhost:9090/")!)
        try client.ner(sentence: "this is a test") {
            defer {
                expectiation.fulfill()
            }

            guard case .success(let value) = $0 else {
                XCTFail("should have succeeded")
                return
            }
            XCTAssertEqual(
                value,
                [
                    Token(text: "this", tag: "DT", lemma: "this", entity: nil),
                    Token(text: "is", tag: "VBZ", lemma: "be", entity: nil),
                    Token(text: "a", tag: "DT", lemma: "a", entity: nil),
                    Token(text: "test", tag: "NN", lemma: "test", entity: nil)
                ]
            )
        }

        waitForExpectations(timeout: 10) { error in
            error.map { XCTFail(String(describing: $0)) }
        }
    }

    static var allTests: [(String, (SpacyClientTests) -> () throws -> ())] = [
        ("testClient", testClient),
    ]
}
