//
//  ApiClient.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

protocol APIClient {
    func send<T: Decodable>(
        _ request: APIRequest
    ) async throws -> T

    /// Sends a request whose response body is irrelevant (e.g. 204 No Content).
    func send(_ request: APIRequest) async throws
}

struct APIRequest {
    let path: String
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var body: Data?
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
