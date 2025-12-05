//
//  InventoryAPIClient.swift
//  Inventory App
//
//  Created by Connor Bailey on 12/4/25.
//

import Foundation

struct InventoryAPIClient {
    static let shared = InventoryAPIClient()
    
    // Flask server
    // TODO: Change how this is handled in production
    private let baseURL = URL(string: "http://97.107.129.189:5000")!
    
    // MARK: - Helpers
    
    // Make the request to the server
    private func makeRequest(path: String, method: String, body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // DEBUG: Remove this after testing
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    // Validate the response
    private func validate(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidStatusCode(-1)
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            // Try to extract error message from JSON
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let message = json["message"] as? String {
                    throw APIError.serverMessage(message)
                } else if let error = json["error"] as? String {
                    throw APIError.serverMessage(error)
                }
            }
            throw APIError.invalidStatusCode(httpResponse.statusCode)
        }
    }
    
    // MARK: - Public API
    
    // Makes a GET request to the end-point for all items in the db
    func getAllItems() async throws -> [InventoryItem] {
        let request = try makeRequest(path: "/get-all-items", method: "GET")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
        
        do {
            return try jsonDecoder.decode([InventoryItem].self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
    
    // Makes a POST request to the end-point to add an item in the db
    func addItem(item: InventoryItem) async throws -> InventoryItem {
        let bodyData = try jsonEncoder.encode(item)
        let request = try makeRequest(path: "/add-item", method: "POST", body: bodyData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
        
        return item
    }
    
    // Makes a POST request to the end-point to delete an item in the db
    func deleteItem<ID>(id: ID) async throws where ID: CustomStringConvertible {
        let payload = DeleteItemPayload(id: String(describing: id))
        let bodyData = try jsonEncoder.encode(payload)
        let request = try makeRequest(path: "/delete-item", method: "POST", body: bodyData)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
        // TODO: Decode any response if needed
    }

    // Sends the full InventoryItem as JSON and expects the updated item back.
    func updateItem(_ item: InventoryItem) async throws -> InventoryItem {
        let bodyData = try jsonEncoder.encode(item)
        let request = try makeRequest(path: "/modify-item", method: "POST", body: bodyData)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
        
        return item
    }

    // Simple ping to test connectivity.
    func ping() async throws -> Bool {
        let request = try makeRequest(path: "/ping", method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)

        if let string = String(data: data, encoding: .utf8) {
            return string.lowercased().contains("pong")
        }
        return true
    }
}
