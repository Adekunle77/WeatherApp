//
//  WeathersModel.swift
//  WeatherApp
//
//  Created by Ade Adegoke on 01/12/2017.
//  Copyright © 2017 AKA. All rights reserved.
//

import Foundation
struct WeathersModel: Codable {
    let summary: String
    let icon: String
    let temperatureMax: Double
}
struct ResponseRoot: Decodable {
    let daily: Daily
}
struct Daily: Decodable {
    let data: [WeathersModel]
}
