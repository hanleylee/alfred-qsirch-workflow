//
//  SearchResult.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//
import AlfredWorkflowScriptFilter

public struct SearchResult: Codable, @unchecked Sendable {
    public struct Item: Codable {
        public struct Preview: Codable {
            public struct Info: Codable {

                public let key: String
                public let display: String
                public let value: CustomCodableAny
            }

            public let container_type: CustomCodableAny?
            public let info: [Info]
        }
        public struct Actions: Codable {
            public let download: String
            public let open: String
            public let share: String
            public let icon: String
        }

        public let owner: String
        /// without extension
        public let name: String
        public let id: String
        public let title: String
        public let preview: Preview?
        public let hidden: Bool
        public let type: String
        public let size: Int
        public let actions: Actions
        /// dir path of file
        public let path: String
        public var `extension`: String?
    }

    public let total: Int
    public let items: [Item]
}

