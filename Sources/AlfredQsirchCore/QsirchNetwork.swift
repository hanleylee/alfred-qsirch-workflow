//
//  QsirchNetwork.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

import Foundation
import SwiftUI

// MARK: - Network

actor QsirchNetwork {
    @AppStorage("QNAP_API_SESSION_ID")
    private var session: String = ""

    private let domain: String
    private let username: String
    private let password: String

    init(domain: String, username: String, password: String) {
        self.domain = domain
        self.username = username
        self.password = password
    }

    func login() async throws -> [String: Any]? {
        let body = [
            "account": username,
            "password": password,
        ]
        if let url = CommonTools.assembleURL("/qsirch/latest/api/login/", domain: self.domain),
           let response: LoginResult = try await request(url, body: body, method: "POST", requireSession: false)
        {
            let sid = response.qqs_sid
            session = sid
        }
        return nil
    }

    func request<T: Decodable>(
        _ urlString: String,
        body: [String: Any]? = nil,
        method: String = "GET",
        requireSession: Bool = true,
        retriedLoginTimes: Int = 0
    ) async throws -> T {
        if requireSession && session.isEmpty { // require session but no session or session invalid, re-login and retry
            print("Logging in...")
            _ = try await login()
            return try await request(urlString)
        }

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add session cookie
        if requireSession && !session.isEmpty {
            request.setValue("QQS_SID=\(session)", forHTTPHeaderField: "Cookie")
        }

        // Add request body
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    if let errorResponse = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let error = errorResponse["error"] as? [String: Any],
                       let code = error["code"] as? Int,
                       code == 101
                    {
                        throw QsirchError.sessionExpired
                    } else {
                        throw QsirchError.networkError(message: "Unauthorized access", code: httpResponse.statusCode)
                    }
                } else if !(200 ... 299).contains(httpResponse.statusCode) {
                    throw QsirchError.networkError(message: "HTTP error: \(httpResponse.statusCode)", code: httpResponse.statusCode)
                }
            }

            return try JSONDecoder().decode(T.self, from: responseData)
        } catch QsirchError.sessionExpired {
            if retriedLoginTimes < 1 { // retry one time
                _ = try await login()
                return try await self.request(urlString, retriedLoginTimes: retriedLoginTimes + 1)
            } else {
                throw QsirchError.sessionExpired
            }
        } catch {
            throw error
        }
    }
}
