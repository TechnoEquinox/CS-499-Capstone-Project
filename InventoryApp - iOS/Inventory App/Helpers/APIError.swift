//
//  APIError.swift
//  Inventory App
//
//  Created by Connor Bailey on 12/4/25.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidStatusCode(Int)
    case decodingFailed
    case serverMessage(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidStatusCode(let code):
            return "Invalid status code: \(code)"
        case .decodingFailed:
            return "Failed to decode data"
        case .serverMessage(let message):
            return message
        }
    }
}
