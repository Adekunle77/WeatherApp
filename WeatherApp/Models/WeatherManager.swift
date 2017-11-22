//
//  WeatherManager.swift
//  TheWeatherApp
//
//  Created by Ade Adegoke on 31/07/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//

import Foundation

class WeatherManager {
    static let shared = WeatherManager()
    
    func weatherFromJsonUrl(withLocation userLocation: String, completion: @escaping ([WeatherModel]) -> Void) {

    let darkSkyUrl = "https://api.darksky.net/forecast/b4821eebc02a87aac50443248fe7b3a9/"

    let url = darkSkyUrl + userLocation

    let request = URLRequest(url: URL(string: url)!)

        let task = URLSession.shared.dataTask(with: request) {(data: Data?, _: URLResponse?, error: Error?) in

            var weatherArray: [WeatherModel] = []

            if let data = data {

                do {

                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let dailyWeather = json["daily"] as? [String: Any] {
                            if let dailyData = dailyWeather["data"] as? [[String: Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? WeatherModel(json: dataPoint) {
                                        weatherArray.append(weatherObject)
                                    }

                                }
                            }

                        }

                    }

                } catch {
                    print(error.localizedDescription)
                }
                completion(weatherArray)
            }

        }
        task.resume()
    }
}
