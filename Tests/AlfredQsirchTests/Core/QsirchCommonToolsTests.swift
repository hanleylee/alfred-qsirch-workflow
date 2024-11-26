//
//  File.swift
//
//
//  Created by Hanley Lee on 2024/11/25.
//

@testable import AlfredQsirchCore
import Foundation
import XCTest

final class QsirchCommonToolsTests: QsirchBaseTests {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAssembleURLWithJustPath() {
        let domain = "http://example.com"
        let path = "/qsirch/latest/api/search"
        let expectedResult = domain + path
        XCTAssertEqual(CommonTools.assembleURL(path, domain: domain), expectedResult)
    }

    func testAssembleURLWithPathAndParams() {
        let domain = "http://example.com"
        let path = "/qsirch/latest/api/search"
        let params = ["name": "Hanley", "country": "cn"]
        let possibleResults: Set<String> = [
            "http://example.com/qsirch/latest/api/search?name=Hanley&country=cn",
            "http://example.com/qsirch/latest/api/search?country=cn&name=Hanley",
        ]
        let actualResult = CommonTools.assembleURL(path, domain: domain, params: params)
        XCTAssertTrue(
            possibleResults.contains(actualResult!),
            "Generated URL (\(actualResult!)) is not in the list of expected results: \(possibleResults)"
        )
    }

    func testAssembleURLWithPathAndEncodedParams() {
        let domain = "http://example.com"
        let path = "/qsirch/latest/api/search?name=Hanley&country=cn"
        let expectedResult = domain + path
        XCTAssertEqual(CommonTools.assembleURL(path, domain: domain), expectedResult)
    }

    func testAssembleURLWithPathAndEmptyParams() {
        let domain = "http://example.com"
        let path = "/qsirch/latest/api/search?name=Hanley&country=cn"
        let params: [String: Any] = [:]
        let expectedResult = "http://example.com/qsirch/latest/api/search?"

        XCTAssertEqual(CommonTools.assembleURL(path, domain: domain, params: params), expectedResult)
    }
}
