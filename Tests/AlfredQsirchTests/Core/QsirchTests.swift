//
//  File.swift
//
//
//  Created by Hanley Lee on 2024/11/25.
//

@testable import AlfredQsirchCore
import Foundation
import XCTest

final class QsirchTests: QsirchBaseTests {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSearchWithQuery() async throws {
        guard
            let domain = ProcessInfo.processInfo.environment["ALFRED_QNAP_DOMAIN"],
            let username = ProcessInfo.processInfo.environment["ALFRED_QNAP_USERNAME"],
            let password = ProcessInfo.processInfo.environment["ALFRED_QNAP_PASSWORD"]
        else {
            XCTFail("Missing required environment variables")
            return
        }

        let qsirch = Qsirch(
            domain: domain,
            username: username,
            password: password
        )

        let result = try await qsirch.search(query: "hello", limit: 50)
        XCTAssertNotEqual(result?.items.count, 0, "Result should not empty")
    }
}
