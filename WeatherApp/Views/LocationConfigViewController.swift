//
//  LocationConfigViewController.swift
//  TheWeatherApp
//
//  Created by Ade Adegoke on 25/09/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//
import CoreLocation
import UIKit
import CoreData
import GooglePlaces
import GoogleMaps


class LocationConfigViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak private var checkLocationOutlet: UIButton!

    private var address = [String]()
    private var coreLocationManager = CLLocationManager()
    private var userLat: String = ""
    private var userLong: String = ""
    private var usersLocality: String = ""
    private var usersArea: String = ""
    private var userCountry: String = ""
    private let reachability = Reachability()!
    private let likelyPlaces: [GMSPlace] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        coreLocationManager.requestWhenInUseAuthorization()
        coreLocationManager.startUpdatingLocation()
        self.view.backgroundColor = UIColor.weatherBlue
        
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    func alertView(title: String, message: String) {
        let title = title
        let message = message
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
    }
    
    @objc func internetChanged(note: NSNotification) {
        if let reachability = note.object as? Reachability {
        if reachability.connection == .wifi {
            print("Wifi")
        }
    }
}
    @objc func timeToMoveOn() {
       DispatchQueue.main.async {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
            let results = try context.fetch(request)
            if results.count > 0 {
                for item in results as! [NSManagedObject] {
                    if let name = item.value(forKey: "address") as? String {
                        self.address.insert(name, at: 0)
                        self.address.append(name)
                    }
                }
            }
        } catch {
            print("there are issues")
        }
        
        
            if self.reachability.connection == .wifi {
                if CLLocationManager.locationServicesEnabled() {
                    //
                    switch(CLLocationManager.authorizationStatus()) {
                    case .notDetermined, .restricted, .denied:
                        self.coreLocationManager.requestWhenInUseAuthorization()
                    case .authorizedAlways, .authorizedWhenInUse:
                        self.performSegue(withIdentifier: "locationConfigID", sender: self)
                    }
                } else {
                    print("Location services is not enabled")
                }
                } else if self.reachability.connection == .cellular {
                if CLLocationManager.locationServicesEnabled() {
                    switch(CLLocationManager.authorizationStatus()) {
                    case .notDetermined, .restricted, .denied:
                        self.alertView(title: "Location Service", message: "Please enable Location Service.")
                        self.coreLocationManager.requestWhenInUseAuthorization()
                    case .authorizedAlways, .authorizedWhenInUse:
                        self.performSegue(withIdentifier: "locationConfigID", sender: self)
                    }
                } else {
                    print("Location services is not enabled")
                }
                } else {
                    self.alertView(title: "Online Connnection!", message: "Your mobile device is currently not online.")
                }
            }
        }

// getting the users current location
func locationManager(_ coreLocationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // getting the first element of the array of the user location
    if let location = locations.first {
        // Converting the above latitude & longitude into a string.
        self.userLat = String(location.coordinate.latitude)
        self.userLong = String(location.coordinate.longitude)
        self.coreLocationManager.stopUpdatingLocation()
    }
    
    guard let reverseGeocodeLocation = coreLocationManager.location else {return}
    
    CLGeocoder().reverseGeocodeLocation(reverseGeocodeLocation, completionHandler: {(placemarks, error) -> Void in
        
        if (error != nil) {
            print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
            
            return
        }
        guard let addressLocation = placemarks else {return}
        
        if addressLocation.count > 0 {
                let pm = addressLocation[0]
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
}

func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            coreLocationManager.stopUpdatingLocation()
            guard let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : "" else {return}
            guard let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : "" else {return}
            guard let country = (containsPlacemark.country != nil) ? containsPlacemark.country : "" else {return}
            usersLocality = locality
            usersArea = administrativeArea
            userCountry = country
    }
}

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }

@IBAction func checkLocation(_ sender: Any) {
    // Core Data. Get user pervious saved searched location
    DispatchQueue.main.async {
    let appDel = UIApplication.shared.delegate as! AppDelegate
    let context = appDel.persistentContainer.viewContext
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
            let results = try context.fetch(request) 
            if results.count > 0 {
                for item in results as! [NSManagedObject] {
                    
                    if let name = item.value(forKey: "address") as? String {
                        self.address.insert(name, at: 0)
                        self.address.append(name)
                    }
                }
            }
        } catch {
            print("there are issues")
        }
    }
    DispatchQueue.main.async {
        if self.reachability.connection == .wifi {
        // switch statement to check if the users location servivce is enable
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                
                 self.alertView(title: "Location Service", message: "Please enable Location Service.")
                self.coreLocationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                
               self.performSegue(withIdentifier: "locationConfigID", sender: self)
            }
        } else {
            print("Location services is not enabled")
        }

        } else if self.reachability.connection == .cellular {
            if CLLocationManager.locationServicesEnabled() {
                //
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    self.coreLocationManager.requestWhenInUseAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                    self.performSegue(withIdentifier: "locationConfigID", sender: self)
                }
            } else {
                print("Location services is not enabled")
            }
        } else {
         self.alertView(title: "Online Connnection!", message: "Your mobile device is currently not online.")
        }
    }
}
    
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "locationConfigID" {
            guard let enterLocationVC: EnterLocationViewController = segue.destination as? EnterLocationViewController else {return}
            enterLocationVC.revievedSavedLocation = address
            enterLocationVC.userLatitude = self.userLat
            enterLocationVC.userLongitude = self.userLong
            enterLocationVC.address = self.usersLocality
            enterLocationVC.area = self.usersArea
        }
    }
}
