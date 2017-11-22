//
//  WeatherModel.swift
//  TheWeatherApp
//
//  Created by Ade Adegoke on 31/07/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//

import Foundation

struct WeatherModel {
    let summary: String
    let icon: String
    let temperature: Double

    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }

    init(json: [String: Any]) throws {
        guard let summary = json["summary"] as? String else { throw SerializationError.missing("summary is missing")}
        guard let icon = json["icon"] as? String else { throw SerializationError.missing("icon is missing")}
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("temperature is missing")
        }

        self.summary = summary
        self.icon = icon
        self.temperature = temperature
    }
}
