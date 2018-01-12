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
    
    func weatherFromJsonUrl(withLocation userLocation: String, completion: @escaping ([WeathersModel]) -> Void) {

    let darkSkyUrl = "https://api.darksky.net/forecast/b4821eebc02a87aac50443248fe7b3a9/"
    let url = darkSkyUrl + userLocation
    let request = URLRequest(url: URL(string: url)!)
    let task = URLSession.shared.dataTask(with: request) {(data: Data?, _: URLResponse?, error: Error?) in
    var weathersArray: [WeathersModel] = []
        print(weathersArray, "Worried")
    if let data = data {

        do {
            let responseRoot = try JSONDecoder().decode(ResponseRoot.self, from: data)
            let weatherModelss = responseRoot.daily.data
            weathersArray = weatherModelss
            }catch {
                    print(error.localizedDescription)
                    }
            print(weathersArray, "Hello use the key")
            completion(weathersArray)
            }
        }
        task.resume()
    }
}
