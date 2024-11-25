//
//  CommonTools.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/24.
//

import Foundation

enum CommonTools {
    /// Assemble URL
    /// - Parameters:
    ///   - path: path
    ///   - params: parameters will be encoded to the url
    /// - Returns: the full url which consistent with domain, path and parameters
    static func assembleURL(_ path: String, domain: String, params: [String: Any]? = nil) -> String? {
        guard var urlComponents = URLComponents(string: domain + path) else {
            return nil // 如果 baseURL 无效，返回 nil
        }

        if let params {
            // 将 params 转换为 URLQueryItem 列表
            urlComponents.queryItems = params.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }

        // 返回拼接好的 URL 字符串
        return urlComponents.url?.absoluteString
    }
}
