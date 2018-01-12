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

class EnterLocationViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var cancelButton: UIButton!
    @IBOutlet weak private var searchButtonOne: UIButton!
    @IBOutlet weak private var searchButtonTwo: UIButton!
    @IBOutlet weak private var blueBackgroundView: UIView!
    @IBOutlet weak private var locationMapView: GMSMapView!
    @IBOutlet weak private var userEnteredLocation: UITextField!
    private var addressesFromCoreData = AddressesSaved().addressesFromCoreData()
    private let reachability = Reachability()!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewForLocation()
        userEnteredLocation.delegate = self
        userEnteredLocation.borderStyle = .none
        userEnteredLocation.backgroundColor = UIColor.white
        userEnteredLocation.layer.cornerRadius = 7.5
        blueBackgroundView.layer.cornerRadius = 10.0
        blueBackgroundView.backgroundColor = UIColor.weatherBlue
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationDidUpdate), name: Notification.Name(rawValue: LocationService.didUpdate), object: nil)
        
        if addressesFromCoreData.count == 0 {
            searchButtonOne.setTitle("No saved searches", for: .normal)
        } else {
            searchButtonOne.setTitle(addressesFromCoreData[0].address, for: .normal)
        }
        if addressesFromCoreData.count <= 1 {
            searchButtonTwo.setTitle("", for: .normal)
        } else {
            searchButtonTwo.setTitle(addressesFromCoreData[1].address, for: .normal)
        }
      
    }

    @objc func locationDidUpdate(notification: Notification) {
       updateViewForLocation()
    }
   
    private func updateViewForLocation() {
        guard let coordinate = LocationService.shared.currentCoordinate else {
            return }
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 15.0)
        self.locationMapView.moveCamera(GMSCameraUpdate.setCamera(camera))
        let marker = GMSMarker()
        marker.position = camera.target
        marker.appearAnimation = .pop
        marker.title = LocationService.shared.usersLocality
        marker.snippet = LocationService.shared.usersArea
        marker.map = self.locationMapView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       searchKeyTriggered()
    UIView.animate(withDuration: 0.4, animations: { self.scrollView.contentOffset.y = 0 })
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.contentOffset.y = +170
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    UIView.animate(withDuration: 0.4, animations: {
      self.scrollView.contentOffset.y = 0
    })
    textField.resignFirstResponder()
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.contentOffset.y = -0
        })
        self.userEnteredLocation.resignFirstResponder()
        self.userEnteredLocation.text = ""
    }
    
    func checkOnlineConnection(address: Coordinate) {
        guard let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVController") as? ViewController else {return}
        
        let lat = String(address.latitude); let long = String(address.longitude)
        secondVC.queryLocation = address
        secondVC.queryString = lat + "," + long
        print(address, "checkOnlineConnection()")
            DispatchQueue.main.async {
                if self.reachability.connection == .wifi {
                    self.present(secondVC, animated: true, completion: nil)
                } else if self.reachability.connection == .cellular {
                    self.present(secondVC, animated: true, completion: nil)
                } else {
                    self.presentAlert(title: "Online Connnection!", message: "Your mobile device is currently not online.")
            }
        }
    }
    
    func searchKeyTriggered() {
        if userEnteredLocation.text == "" {
            presentAlert(title: "Empty Textfield!", message: "Please enter an address.")
        } else {
        guard let enterAddress = self.userEnteredLocation.text else {return}
           
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(enterAddress) { (placemarks, error) in
            if error != nil {
                self.userEnteredLocation.text = ""
                self.presentAlert(title: "Unknown location!", message: "Please enter another location.")
            }
            guard let placemark = placemarks?.first?.location else {return}
            let addressCoordinte: Coordinate = (placemark.coordinate.latitude, placemark.coordinate.longitude)
            let addressAndLatLong: AddressWithCoordinate = (enterAddress, addressCoordinte)
                SavingAddress.shared.savingAddressToCoreData(save: addressAndLatLong)
                self.checkOnlineConnection(address: addressAndLatLong.coordinate)
            }
        }
    }
    
    @IBAction func usersSavedLocationNoOne(_ sender: UIButton) {
        self.checkOnlineConnection(address:addressesFromCoreData[0].coordinate)
    }
    
    @IBAction func usersSavedLocationNoTwo(_ sender: UIButton) {
        self.checkOnlineConnection(address:addressesFromCoreData[1].coordinate)
    }
   
    @IBAction func usersCurrentLocation(_ sender: Any) {
        guard let coordinate = LocationService.shared.currentCoordinate else {return }
        self.checkOnlineConnection(address: coordinate)
        print(coordinate, "usersCurrentLocation()")
        if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "weatherVController") as? ViewController {
            DispatchQueue.main.async {
                if self.reachability.connection == .wifi {
                    self.present(secondVC, animated: true, completion: nil)
                } else if self.reachability.connection == .cellular {
                    self.present(secondVC, animated: true, completion: nil)
                } else {
                    self.presentAlert(title: "Online Connnection!", message: "Your mobile device is currently not online.")
                }
            }
        }
    }
}
