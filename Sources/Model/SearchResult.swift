//
//  SearchResult.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

struct SearchResult: Codable, @unchecked Sendable {
    struct Item: Codable {
        struct Preview: Codable {
            struct Info: Codable {

                let key: String
                let display: String
                let value: CustomCodableAny
            }

            let container_type: CustomCodableAny?
            let info: [Info]
        }
        struct Actions: Codable {
            let download: String
            let open: String
            let share: String
            let icon: String
        }

        let owner: String
        let name: String
        let id: String
        let title: String
        let preview: Preview?
        let hidden: Bool
        let type: String
        let size: Int
        let actions: Actions
    }

    let total: Int
    let items: [Item]
}
