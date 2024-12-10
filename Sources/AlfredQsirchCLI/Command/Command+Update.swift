//
//  File.swift
//
//
//  Created by Hanley Lee on 2024/11/26.
//

import AlfredCore
import AlfredWorkflowScriptFilter
import AlfredWorkflowUpdaterCore
import ArgumentParser
import Foundation

struct UpdateCommand: AsyncParsableCommand {
    enum Action: String, ExpressibleByArgument {
        case check
        case open
        case download
        case update
    }

    static let configuration = CommandConfiguration(commandName: "update", abstract: "Update workflow", discussion: "")

    func run() async throws {
        let updater = Updater(githubRepo: CommonTools.githubRepo, workflowAssetName: CommonTools.workflowAssetName)
        switch action {
        case .check:
            if let release = try await updater.check(maxCacheAge: 0) {
                ScriptFilter.item(
                    Item(title: "Latest version: \(release.tagName)")
                        .subtitle("Current version is \(AlfredConst.workflowVersion ?? "None")")
                )
            }
        case .open:
            try await updater.openLatestReleasePage()
        case .download:
            try await updater.downloadLatestRelease()
        case .update:
            try await updater.updateToLatest()
        }
    }

    @Option(help: ArgumentHelp("Action used to update subcommand", valueName: "check|open|download|update"))
    var action: Action = .check
}
