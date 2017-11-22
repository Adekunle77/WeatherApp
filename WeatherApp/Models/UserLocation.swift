//
//  UserLocation.swift
//  TheWeatherApp
//
//  Created by Ade Adegoke on 31/07/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//

import Foundation
import CoreLocation

class UserLocation: CLLocation, CLLocationManagerDelegate {
    let userManger = CLLocationManager()
    var userLaitude: String?
    var userLongitude: String?

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        print(location.coordinate.latitude)
    }

func getUserLocation() {
        userManger.desiredAccuracy = kCLLocationAccuracyBest
        userManger.requestWhenInUseAuthorization()
        userManger.startUpdatingLocation()
    }
}
