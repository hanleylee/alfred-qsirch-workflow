//
//  File.swift
//  
//
//  Created by Hanley Lee on 2024/11/25.
//

import Foundation
@testable import AlfredQsirchCore
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
