//
//  File.swift
//  
//
//  Created by Hanley Lee on 2024/11/25.
//

import Foundation
@testable import AlfredQsirchCore
import XCTest

final class QsirchNetworkTests: QsirchBaseTests {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLogin() async throws {
        guard
            let domain = ProcessInfo.processInfo.environment["ALFRED_QNAP_DOMAIN"],
            let username = ProcessInfo.processInfo.environment["ALFRED_QNAP_USERNAME"],
            let password = ProcessInfo.processInfo.environment["ALFRED_QNAP_PASSWORD"] else {
            XCTFail("Missing required environment variables")
            return
        }

        let network = QsirchNetwork(
            domain: domain,
            username: username,
            password: password
        )

        let mockSID = "qwertyuiop"

        mockDefaults.set(mockSID, forKey: "QNAP_API_SESSION_ID")

        let initialSession = await network.session
        XCTAssertEqual(initialSession, mockSID, "Session should match the mock value.")

        try _ = await network.login()
        let updatedSession = await network.session
        XCTAssertNotEqual(updatedSession, mockSID, "Session should update after login.")
    }

    func testRequestRequireSession() {

    }

    func testRequestNoRequireSession() {

    }
}
