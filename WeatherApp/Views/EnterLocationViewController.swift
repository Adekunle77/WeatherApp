////
//  EnterLocationViewController.swift
//  TheWeatherApp
//
//  Created by Ade Adegoke on 21/09/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//
import CoreData
import CoreLocation
import UIKit
import GoogleMaps

//protocol SendUserLocation {
//    func locationFromVC(location: String)
//}

class EnterLocationViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak private var cancelButtonOutlet: UIButton!
    @IBOutlet weak private var searchButtonOne: UIButton!
    @IBOutlet weak private var searchButtonTwo: UIButton!
    @IBOutlet weak private var blueBackgroundView: UIView!
    @IBOutlet weak private var whatLocationLabel: UILabel!
    @IBOutlet weak private var lcationMapView: GMSMapView!
    @IBOutlet weak private var searchButtonOutlet: UIButton!
    @IBOutlet weak private var userEnteredLocation: UITextField!
    @IBOutlet weak private var useCurrentLocationOutlet: UILabel!
    @IBOutlet weak private var useCurrentLocButt: UIButton!

    var revievedSavedLocation = [String]()
    var locationSavedOne: String = ""
    var userLatitude: String = ""
    var userLongitude: String = ""
    var address: String = ""
    var area: String = ""

    private let locationManager = CLLocationManager()
    private var userCurrentLocation: String?
    private let reachability = Reachability()!
   // var sendUserLocationDelegate: SendUserLocation!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up for getting the current users location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Do any additional setup after loading the view.
        userEnteredLocation.delegate = self
        userEnteredLocation.borderStyle = .none
        userEnteredLocation.backgroundColor = UIColor.white
        userEnteredLocation.layer.cornerRadius = 8.0

        blueBackgroundView.layer.cornerRadius = 10.0
        blueBackgroundView.backgroundColor = UIColor.weatherBlue
        cancelButtonOutlet.frame.origin.x = 373

        if revievedSavedLocation.count == 0 {
        searchButtonOne.setTitle("No saved searches", for: .normal)
        } else {
            searchButtonOne.setTitle(revievedSavedLocation[0], for: .normal)
        }
        if revievedSavedLocation.count <= 1 {
           searchButtonTwo.setTitle("", for: .normal)
        } else {
            searchButtonTwo.setTitle(revievedSavedLocation[1], for: .normal)
        }

        // setting the background view with google maps
        DispatchQueue.main.async {
        let camera = GMSCameraPosition.camera(withLatitude: Double(self.userLatitude)!, longitude: Double(self.userLongitude)!, zoom: 15.0)
        let marker = GMSMarker()
        marker.position = camera.target
        marker.appearAnimation = .pop

        marker.title = self.address
        marker.snippet = self.area
        marker.map = self.lcationMapView
        self.lcationMapView.moveCamera(GMSCameraUpdate.setCamera(camera))
    }
}

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    searchKeyTriggered()
    textField.resignFirstResponder()
    return true
}

func textFieldDidBeginEditing(_ textField: UITextField) {
    UIView.animate(withDuration: 0.4, animations: {
    self.blueBackgroundView.frame.origin.y -= 200
    self.cancelButtonOutlet.frame.origin.x = 280
    self.userEnteredLocation.frame = CGRect(x: 15, y: 16, width: 266, height: 35)
    })
}

func textFieldDidEndEditing(_ textField: UITextField) {
    self.blueBackgroundView.frame.origin.y = 425
    textField.resignFirstResponder()
}

    func alertView(title: String, message: String) {
        let title = title
        let message = message
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
    }
    

@IBAction func cancelButtonAction(_ sender: UIButton) {
    UIView.animate(withDuration: 0.4, animations: {
        self.cancelButtonOutlet.frame.origin.x = 373
        self.blueBackgroundView.frame.origin.y = 425
        self.userEnteredLocation.layer.cornerRadius = 4.0
        self.userEnteredLocation.frame = CGRect(x: 15, y: 16, width: 327, height: 35)
    })
        self.userEnteredLocation.resignFirstResponder()
        self.userEnteredLocation.text = ""
}

func searchKeyTriggered() {

    if userEnteredLocation.text == "" {
        alertView(title: "Empty Textfield!", message: "Please enter an address.")
    } else {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userEnteredLocation.text!) { (placemarks, _) in
            guard let placemark = placemarks?.first?.location else {return}
            let lat = String(placemark.coordinate.latitude)
            let long = String(placemark.coordinate.longitude)
            let enteredLatLong = lat + "," + long

            // Core Data. saving user searched information
            let appDel = UIApplication.shared.delegate as! AppDelegate
            let context = appDel.persistentContainer.viewContext

            let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
            newLocation.setValue(self.userEnteredLocation.text, forKey: "address")
            do {
                try context.save()

            } catch {
                print("It did not save")
            }
            let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVController") as! ViewController
            secondVC.usersLocation = enteredLatLong
            secondVC.userLatitude = lat
            secondVC.userLongitude = long

            DispatchQueue.main.async {
                if self.reachability.connection == .wifi {

                    self.present(secondVC, animated: true, completion: nil)
                } else if self.reachability.connection == .cellular {
                    self.present(secondVC, animated: true, completion: nil)
                } else {
                    self.alertView(title: "Online Connnection!", message: "Your mobile device is currently not online.")
                }
            }
        }
    }
}

@IBAction func usersSavedLocationNoOne(_ sender: UIButton) {
    if searchButtonOne.currentTitle == "No saved searches" {
         self.alertView(title: "Sorry!", message: "There are no saved searches.")
    } else {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(revievedSavedLocation[0]) { (placemarks, _) in
            guard let placemark = placemarks?.first?.location else {return}
            let lat = String(placemark.coordinate.latitude)
            let long = String(placemark.coordinate.longitude)

            if lat.isEmpty {
                print("Sorry this address is unknown")
                // return
            } else {
                let latLong = lat + "," + long
                let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVController") as! ViewController
                secondVC.usersLocation = latLong
                secondVC.userLatitude = lat
                secondVC.userLongitude = long
                DispatchQueue.main.async {
                    if self.reachability.connection == .wifi {
                        self.present(secondVC, animated: true, completion: nil)
                    } else if self.reachability.connection == .cellular {
                        self.present(secondVC, animated: true, completion: nil)
                    } else {
                       self.alertView(title: "Online Connnection!", message: "Your mobile device is currently not online.")
                    }
                }
            }
        }
    }
}


@IBAction func usersSavedLocationNoTwo(_ sender: UIButton) {
    if searchButtonOne.currentTitle == "No saved searches" {
    self.alertView(title: "Sorry!", message: "There are no saved searches.")
        print("do something")
    } else {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(revievedSavedLocation[1]) { (placemarks, _) in
            guard let placemark = placemarks?.first?.location else {return}
            let lat = String(placemark.coordinate.latitude)
            let long = String(placemark.coordinate.longitude)
            if lat.isEmpty {
                print("Sorry this address is unknown")
            } else {
                let latLong = lat + "," + long

                let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVController") as! ViewController
                secondVC.usersLocation = latLong
                secondVC.userLatitude = lat
                secondVC.userLongitude = long
                DispatchQueue.main.async {
                    if self.reachability.connection == .wifi {
                        self.present(secondVC, animated: true, completion: nil)
                    } else if self.reachability.connection == .cellular {
                        self.present(secondVC, animated: true, completion: nil)
                    } else {
                       self.alertView(title: "Online Connnection!", message: "Your mobile device is currently not online.")
                    }
                }
            }
        }
    }
}

@IBAction func usersCurrentLocation(_ sender: Any) {
         let userLocation = self.userLatitude + "," + "" + self.userLongitude
        if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVController") as? ViewController {
        
        secondVC.usersLocation =  userLocation
        secondVC.userLatitude = self.userLatitude
        secondVC.userLongitude = self.userLongitude
            
        DispatchQueue.main.async {
                if self.reachability.connection == .wifi {
                    self.present(secondVC, animated: true, completion: nil)
                } else if self.reachability.connection == .cellular {
                    self.present(secondVC, animated: true, completion: nil)
                } else {
                    self.alertView(title: "Online Connnection!", message: "Your mobile device is currently not online.")
                }
            }
        }
    }
}
