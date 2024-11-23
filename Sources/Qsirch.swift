//
//  Qnap.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

import Foundation

actor Qsirch {
    private let domain: String
    private let username: String
    private let password: String
    private let network: QsirchNetwork
    
    init(domain: String, username: String, password: String) {
        self.domain = domain
        self.network = QsirchNetwork(domain: domain, username: username, password: password)
        
        self.username = username
        self.password = password
    }
    
}

// MARK: - Biz

extension Qsirch {
    func search(query: String, limit: Int) async throws -> SearchResult? {
//        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let params: [String: Any] = [
//            "sort_by": "created",
//            "sort_dir": "desc",
            "limit": limit,
            "q": query
        ]
        guard let url = await network.assembleURL("/qsirch/latest/api/search", params: params) else { return nil }
        
        do {
            let result: SearchResult? = try await self.network.request(url)
            return result
        } catch QsirchError.sessionExpired { // Session expired, login again
            print("Search failed with error")
            throw QsirchError.sessionExpired
        } catch {
            print("Search failed with error: \(error)")
            throw error
        }
    }
}
