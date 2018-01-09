//
//  LocationService.swift
//  WeatherApp
//
//  Created by Ade Adegoke on 10/12/2017.
//  Copyright © 2017 AKA. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate  {
    
    static let shared = LocationServices()
    var currentCoordinate: Coordinate?
    var locationManager: CLLocationManager!
//
//    func currentLocation() -> String {
//        guard let userCurrentLatLong = currentCoordinate else {
//            return ""
//        }
//        print("this", userCurrentLatLong)
//        return userCurrentLatLong
//    }
    
    func startLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        guard let userCurrentLatLong = self.currentCoordinate else {return}
        print(userCurrentLatLong, "crountry")
    }
 
    func locationManager(_ coreLocationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
       // let test = locations.first?.coordinate
        let latLong = locations.first
        guard let lat = latLong?.coordinate.latitude, let long = latLong?.coordinate.longitude else {
            return
        }   
        currentCoordinate = (lat, long)
    }
}
