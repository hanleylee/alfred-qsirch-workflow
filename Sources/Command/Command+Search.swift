//
//  Command+Search.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

import ArgumentParser
import Foundation

struct SearchCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "search", abstract: "Perform a search query on QNAP.", discussion: "")
    @OptionGroup()
    var options: Options

    func run() async throws {
        let qsirch = Qsirch(
            domain: options.domain,
            username: options.username,
            password: options.password
        )

        do {
            guard let result = try await qsirch.search(query: options.name, limit: options.limit) else { return }
            let alfedItems = await AlfredUtil.shared.searchResultToAlfredFileList(result: result, domain: options.domain)
            let jsonData = try JSONEncoder().encode(alfedItems)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            } else {
                print("Failed to convert JSON data to string.")
            }
        } catch QsirchError.sessionExpired {
            print("Session expired. Please re-login.")
        } catch let QsirchError.networkError(message, code) {
            print("Network error: \(message), code: \(code)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}

extension SearchCommand {
    struct Options: ParsableArguments {
//        @Flag(help: "Prints the available products and targets")
//        var listProducts = false
        @Option(help: ArgumentHelp("The domain of QNAP"))
        var domain: String = ProcessInfo.processInfo.environment["ALFRED_QNAP_DOMAIN"] ?? ""

        @Option(help: ArgumentHelp("The domain of QNAP"))
        var username: String = ProcessInfo.processInfo.environment["ALFRED_QNAP_USERNAME"] ?? ""

        @Option(help: ArgumentHelp("The domain of QNAP"))
        var password: String = ProcessInfo.processInfo.environment["ALFRED_QNAP_PASSWORD"] ?? ""

        @Option(help: ArgumentHelp("the max count of result", valueName: "number"))
        var limit: Int = 50

        @Argument(help: "query content")
        var name: String = "example"
    }
}
