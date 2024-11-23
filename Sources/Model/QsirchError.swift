//
//  QsirchError.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

enum QsirchError: Error {
    case sessionExpired
    case networkError(message: String, code: Int)
}

