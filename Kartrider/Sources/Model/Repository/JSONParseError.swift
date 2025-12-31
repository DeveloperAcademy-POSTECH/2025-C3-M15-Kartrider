//
//  JSONParseError.swift
//  Kartrider
//
//  Created by J on 6/28/25.
//

import Foundation

enum JSONParseError: Error {
    case fileNotFound(String)
    case decodeFailed(String)
    case unsupportedType(Any.Type)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .decodeFailed(let path):
            return "Decode failed: \(path)"
        case .unsupportedType(let type):
            return "Unsupported type: \(type)"
        }
    }
}

