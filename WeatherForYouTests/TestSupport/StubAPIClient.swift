//
//  StubAPIClient.swift
//  WeatherForYouTests
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation
@testable import WeatherForYou

/// A scripted `APIClient` that records requests and returns a canned result.
@MainActor
final class StubAPIClient: APIClient {
    var result: Any?
    var error: Error?
    private(set) var requests: [APIRequest] = []

    func send<T: Decodable>(_ request: APIRequest) async throws -> T {
        requests.append(request)

        if let error {
            throw error
        }

        guard let result = result as? T else {
            throw APIError.emptyResponse
        }

        return result
    }
}
