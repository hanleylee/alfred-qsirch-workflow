//
//  Command+Search.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

import AlfredWorkflowScriptFilter
import AlfredWorkflowUpdaterCore
import ArgumentParser
import Foundation
import QsirchCore

struct SearchCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "search", abstract: "Perform a search query on QNAP.", discussion: "")
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

    func run() async throws {
        let qsirch = Qsirch(
            domain: domain,
            username: username,
            password: password
        )

        do {
            guard let result = try await qsirch.search(query: name, limit: limit) else { return }
            addQsirchToAlfredResult(model: result, domain: domain)
            let updater = Updater(githubRepo: CommonTools.githubRepo, workflowAssetName: CommonTools.workflowAssetName)
            if let release = try await updater.check(maxCacheAge: 1440), let currentVersion = AlfredUtils.currentVersion {
                if currentVersion.compare(release.tagName, options: .numeric) == .orderedAscending {
                    ScriptFilter.item(
                        Item(title: "New version available on GitHub")
                            .subtitle("current version: \(currentVersion), remote version: \(release.tagName)")
                            .arg("update")
                    )
                }
            }
            print(ScriptFilter.output())
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
    public func addQsirchToAlfredResult(model: SearchResult, domain: String) {
        if model.items.isEmpty {
            ScriptFilter.item(
                AlfredWorkflowScriptFilter.Item(title: "No matched")
                    .subtitle("There is no matched file in your QNAP: \(domain)")
                    .arg("empty")
            )
        } else {
            for item in model.items {
                let title = item.title
                let dirPath = item.path
                let fileName = item.name
                let fileExtension = item.extension ?? ""
                guard let filePath = item.preview?.info.first(where: { $0.key == "path" })?.value.value as? String else { continue }
                let pathInMac = "/Volumes/\(filePath)"
                let iconUrl = domain + item.actions.icon

                let fileStationUrl = QsirchTools.assembleURL(
                    "/filestation/",
                    domain: domain,
                    params: ["path": dirPath, "file": fileExtension.isEmpty ? fileName : "\(fileName).\(fileExtension)"]
                )
                let downloadUrl = QsirchTools.assembleURL(item.actions.download, domain: domain)

                ScriptFilter.add(
                    AlfredWorkflowScriptFilter.Item(title: title)
                        .subtitle(pathInMac)
                        .arg(pathInMac)
                        .icon(.init(path: pathInMac, type: .fileicon))
                        .quicklookurl(pathInMac)
                        .mods(
                            Cmd().subtitle("Reveal file in Finder").arg(pathInMac),
                            Alt().subtitle("Download file").arg(downloadUrl ?? ""),
                            Ctrl().subtitle("Open file in FileStation").arg(fileStationUrl ?? "")
                        )
                )
            }
        }
    }
}
