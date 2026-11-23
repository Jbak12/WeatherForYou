import Foundation
import XCTest
@testable import WeatherForYou

@MainActor
final class DefaultAPIClientTests: XCTestCase {
    func testSendBuildsURLAndDecodesJSON() async throws {
        let (client, session) = try makeClient()
        defer { session.invalidateAndCancel() }

        let city = "São Tomé & Príncipe"
        let urlString: String = try await client.send(
            APIRequest(path: "/v1/search", queryItems: [URLQueryItem(name: "name", value: city)])
        )

        let components = try XCTUnwrap(URLComponents(string: urlString))
        XCTAssertEqual(components.host, "example.com")
        XCTAssertEqual(components.path, "/api/v1/search")
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "name", value: city)])
    }

    func testSendPreservesHTTPErrorStatusAndBody() async throws {
        let (client, session) = try makeClient()
        defer { session.invalidateAndCancel() }

        do {
            // The response body is valid JSON, but a non-2xx status must still fail.
            let _: String = try await client.send(APIRequest(path: "/unavailable"))
            XCTFail("Expected an HTTP error.")
        } catch let APIError.httpError(statusCode, body) {
            XCTAssertEqual(statusCode, 503)
            XCTAssertEqual(body, Data(#""Unavailable""#.utf8))
        }
    }

    func testSendTranslatesURLSessionCancellation() async throws {
        let (client, session) = try makeClient()
        defer { session.invalidateAndCancel() }

        do {
            let _: String = try await client.send(APIRequest(path: "/cancelled"))
            XCTFail("Expected cancellation.")
        } catch is CancellationError {
            // Expected: the client normalizes URLSession cancellation.
        }
    }

    private func makeClient() throws -> (DefaultAPIClient, URLSession) {
        let baseURL = try XCTUnwrap(URL(string: "https://example.com/api"))
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [APIClientURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return (DefaultAPIClient(baseURL: baseURL, session: session), session)
    }
}

/// Scripts responses by request path so tests can run without a shared handler or a server.
private final class APIClientURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        if url.path == "/api/cancelled" {
            client?.urlProtocol(self, didFailWithError: URLError(.cancelled))
            return
        }

        let isUnavailable = url.path == "/api/unavailable"
        let statusCode = isUnavailable ? 503 : 200
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let data = try JSONEncoder().encode(isUnavailable ? "Unavailable" : url.absoluteString)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
