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
    
    static let didUpdate: String = "CoreLocationDidUpdateLocation"
    
    enum LocationServiceStatus {
        case notDetermined, disabled, denied, authorised
    }

    var addressNoOne: AddressWithCoordinate?
    static let shared = LocationService()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let reachability = Reachability()!
    var status: LocationServiceStatus
    
    var currentCoordinate: Coordinate?
    private var latLongForEnteredAddress: Coordinate = (0, 0)
    var usersLocality: String = ""
    var usersArea: String = ""
    var userCountry: String = ""
    
    override private init() {
        status = .notDetermined
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                status = .notDetermined
                self.locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                status = .denied
            case .authorizedAlways, .authorizedWhenInUse:
                status = .authorised
            }
        } else {
            status = .disabled
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            self.status = .notDetermined
        case .authorizedAlways, .authorizedWhenInUse:
            self.status = .authorised
            LocationService.shared.startLocationManager()
        }
    }
    
    func startLocationManager() {
        locationManager.startUpdatingLocation()
    }
 
    private var didReceiveLocation = false
    func locationManager(_ coreLocationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if didReceiveLocation {
            return
        }

        guard let location = locations.first else {
            return
        }
        didReceiveLocation = true
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        
        coreLocationManager.stopUpdatingLocation()
        
        currentCoordinate = (lat, long)
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            guard let addressLocation = placemarks else {return}

            guard addressLocation.count > 0 else {
                print("Problem with the data received from geocoder") //alert
                return
            }

            let pm = addressLocation[0]
            guard let locality = (pm.locality != nil) ? pm.locality : "" else {return}
            guard let administrativeArea = (pm.administrativeArea != nil) ? pm.administrativeArea : "" else {return}
            guard let country = (pm.country != nil) ? pm.country : "" else {return}

            self.usersLocality = locality
            self.usersArea = administrativeArea
            self.userCountry = country
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocationService.didUpdate), object: self)

        })
    }

    func presentWeatherViewController(for placemarks: [CLPlacemark]?) {
        guard let placemark = placemarks?.first?.location else {return}
        let lat = String(placemark.coordinate.latitude)
        let long = String(placemark.coordinate.longitude)
        if lat.isEmpty {
            print("Sorry this address is unknown") //alert
        } else {
            let latLong = lat + "," + long
            print(" this is \(latLong)")
        }
    }
}
