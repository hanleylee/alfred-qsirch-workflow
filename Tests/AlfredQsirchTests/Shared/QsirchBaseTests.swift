//
//  File.swift
//
//
//  Created by Hanley Lee on 2024/11/25.
//

@testable import AlfredQsirchCore
import Foundation
import XCTest

class QsirchBaseTests: XCTestCase {
    var mockDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        mockDefaults = UserDefaults(suiteName: "MockDefaults")
        CommonTools.sharedUserDefaults = mockDefaults
    }

    override func tearDown() {
        super.tearDown()

        mockDefaults.removePersistentDomain(forName: "MockDefaults")
        mockDefaults = nil
    }
}
