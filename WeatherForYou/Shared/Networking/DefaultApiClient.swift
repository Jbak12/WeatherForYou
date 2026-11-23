//
//  DefaultApiClient.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 22/11/2026.
//

import Foundation

final class DefaultAPIClient: APIClient {

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func send<T: Decodable>(
        _ request: APIRequest
    ) async throws -> T {
        let (data, _) = try await execute(request)

        guard !data.isEmpty else {
            throw APIError.emptyResponse
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(underlying: error, body: data)
        }
    }

    func send(_ request: APIRequest) async throws {
        _ = try await execute(request)
    }
}

private extension DefaultAPIClient {

    func execute(
        _ request: APIRequest
    ) async throws -> (Data, HTTPURLResponse) {
        let urlRequest = try makeURLRequest(from: request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError where error.code == .cancelled {
            // SwiftUI `.task {}` cancels its work when the view goes away.
            // Surface that as `CancellationError`, not as a user-facing failure.
            throw CancellationError()
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                body: data.isEmpty ? nil : data
            )
        }

        return (data, httpResponse)
    }

    func makeURLRequest(from request: APIRequest) throws -> URLRequest {
        let path = request.path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }

        if !request.queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + request.queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = request.body {
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // Caller-supplied headers win, including Accept and Content-Type overrides.
        request.headers.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }

        return urlRequest
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyResponse
    case httpError(statusCode: Int, body: Data?)
    case decodingFailed(underlying: Error, body: Data?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "api.error.invalid_url")
        case .invalidResponse:
            return String(localized: "api.error.invalid_response")
        case .emptyResponse:
            return String(localized: "api.error.empty_response")
        case let .httpError(statusCode, body):
            if let reason = body.flatMap(Self.serverReason) {
                return String(
                    localized: "api.error.status_with_reason",
                    defaultValue: "The server responded with status \(String(statusCode)): \(reason)"
                )
            }
            return String(
                localized: "api.error.status",
                defaultValue: "The server responded with status \(String(statusCode))."
            )
        case let .decodingFailed(underlying, _):
            return String(
                localized: "api.error.decoding",
                defaultValue: "The server response couldn't be read. (\(underlying.localizedDescription))"
            )
        }
    }

    /// Extracts a human-readable message from common error payloads,
    /// e.g. Open-Meteo's `{"error": true, "reason": "..."}`.
    private static func serverReason(from body: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: body),
            let dictionary = object as? [String: Any]
        else {
            return nil
        }

        return dictionary["reason"] as? String ?? dictionary["message"] as? String
    }
}
