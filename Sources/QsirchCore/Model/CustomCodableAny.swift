//
//  CustomCodableAny.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

import Foundation

public struct CustomCodableAny: Codable {
    public let value: Any

    init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else if let arrayValue = try? container.decode([CustomCodableAny].self) {
            self.value = arrayValue.map { $0.value }
        } else if let dictionaryValue = try? container.decode([String: CustomCodableAny].self) {
            self.value = dictionaryValue.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(
                CustomCodableAny.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            let encodableArray = arrayValue.map { CustomCodableAny($0) }
            try container.encode(encodableArray)
        case let dictionaryValue as [String: Any]:
            let encodableDictionary = dictionaryValue.mapValues { CustomCodableAny($0) }
            try container.encode(encodableDictionary)
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }
}
