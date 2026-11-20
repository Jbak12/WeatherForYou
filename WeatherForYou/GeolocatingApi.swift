//
//  GeolocatingApi.swift
//  WeatherForYou
//
//  Created by Jakub Bakalarz on 20/11/2026.
//

import Foundation

struct Location: Codable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let featureCode: String
    let countryCode: String
    let admin1Id: Int?
    let admin3Id: Int?
    let admin4Id: Int?
    let timezone: String
    let population: Int?
    let postcodes: [String]?
    let countryId: Int
    let country: String
    let admin1: String?
    let admin3: String?
    let admin4: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case elevation
        case featureCode = "feature_code"
        case countryCode = "country_code"
        case admin1Id = "admin1_id"
        case admin3Id = "admin3_id"
        case admin4Id = "admin4_id"
        case timezone
        case population
        case postcodes
        case countryId = "country_id"
        case country
        case admin1
        case admin3
        case admin4
    }
}


final class GeolocatingApi {
    static func fetchLocationDummy() async -> Location {
        var components = URLComponents(
            string: "https://geocoding-api.open-meteo.com/v1/search"
        )!

        components.queryItems = [
            URLQueryItem(name: "name", value: "Warsaw"),
            URLQueryItem(name: "count", value: "5"),
            URLQueryItem(name: "language", value: "en")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        var responses: (Data, URLResponse)? = nil
        do  {
            responses = try await URLSession.shared.data(for: request)
        } catch {
            print(" request failed: \(error)")
        }
        let data: Data = responses!.0

        print("RAW RESPONSE (\(data.count) bytes):")
        print(String(data: data, encoding: .utf8) ?? "<non-UTF8, \(data.count) bytes>")

        if let object = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(
               withJSONObject: object,
               options: [.prettyPrinted, .sortedKeys]
           ),
           let text = String(data: pretty, encoding: .utf8) {
            print("PARSED JSON:\n\(text)")
        } else {
            print(" response is not valid JSON — raw output above")
        }

        let Location: Location = try! JSONDecoder().decode(Location.self, from: data)
        return Location
        
    }
}
