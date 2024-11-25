//
//  SearchCommandTests.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/24.
//

import XCTest
import class Foundation.Bundle

final class SearchCommandTests: XCTestCase {
    func testSearchCommandOutput() throws {
        // 获取构建的可执行文件路径
        let fooBinary = productsDirectory.appendingPathComponent("alfred-qsirch-workflow")

        // 创建进程来运行可执行文件
        let process = Process()
        process.executableURL = fooBinary

        // 设置命令行参数
        process.arguments = ["search", "example-query"]

        // 捕获标准输出
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.environment = [
            "QNAP_API_SESSION_ID": "test-session-id",
            "ALFRED_QNAP_DOMAIN": "http://test-domain",
            "ALFRED_QNAP_USERNAME": "test-username",
            "ALFRED_QNAP_PASSWORD": "test-password"
        ]

        try process.run()
        process.waitUntilExit()

        // 获取输出数据
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        // 验证输出内容
        XCTAssertTrue(output.contains("Expected search result substring"), "Output did not contain expected result.")
    }

    /// 获取可执行文件的构建目录
    var productsDirectory: URL {
        #if os(macOS)
        return Bundle.main.bundleURL.deletingLastPathComponent()
        #else
        return Bundle.main.bundleURL
        #endif
    }
}
