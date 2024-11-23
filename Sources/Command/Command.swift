//
//  Command.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

import ArgumentParser
struct Command: AsyncParsableCommand {
    @OptionGroup()
    var options: Options
    
    static let configuration = CommandConfiguration(commandName: "alfred-qsirch", abstract: "Tool used for connecting alfred with Qsirch", discussion: "", subcommands: [SearchCommand.self])
    
    func run() async throws {
        print("Main command run!")
    }
}

extension Command {
    struct Options: ParsableArguments {
        // MARK: - Package Loading
    }
}
