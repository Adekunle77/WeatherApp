//
//  ViewController.swift
//  TheWeatherApp
//
//  Created by Ade Adegoke on 31/07/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import CoreData

private let weatherNavigationID = "weatherNavigationID"

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak private var backgroundView: GMSMapView!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var searchButton: UIButton!
    private var weatherForecast = [WeathersModel]()
    private var addressSaved = AddressesSaved.shared.addressesFromCoreData()
    fileprivate lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter
    }()
    //     UPDATE THIS FROM THE PREVIOUS VIEW CONTROLLER, IF THE USER SELECTS A PREVIOUS SAVED LOCATION, OR IF THEY ENTER A NEW LOCATION  (i.e. TO OVERRIDE GPS LOCATION)
    //
    var queryString: String? = nil
    var queryLocation: Coordinate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: weatherNavigationID)
        collectionView.allowsSelection = false
        searchButton.backgroundColor = UIColor.weatherBlue
        searchButton.layer.cornerRadius = 6.0
  
        guard let coordinate = queryLocation else {
            presentAlert(title: "Coordinates not determined yet, and no specific location provided.", message: "Please try again")
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 15.0)
        let marker = GMSMarker()
        marker.position = camera.target
        marker.map = self.backgroundView
        self.backgroundView.moveCamera(GMSCameraUpdate.setCamera(camera))
        fetchWeatherForSelectedLocation()
    }
    
    
    @IBAction func searchAgain(_ sender: UIButton) {
        self.performSegue(withIdentifier: "searchAgainSegueID", sender: self)
    }
    
    private func fetchWeatherForSelectedLocation() {
        // NOTE FROM SAM:
        //
        //   this is always going to use GPS location... if you want to use the selected
        //   saved location, or new search location, then set the "searchLocation" property
        //
        guard let location = queryString ?? queryStringForCurrentLocation() else {
            presentAlert(title: "Coordinates not determined yet, and no specific location provided.", message: "Please try again")
            return
        }
        WeatherManager.shared.weatherFromJsonUrl(withLocation: location) {(results: [WeathersModel]?) in
            if let fetachedWeather = results {
                self.weatherForecast = fetachedWeather
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func queryStringForCurrentLocation() -> String? {
        guard let coordinate = LocationService.shared.currentCoordinate else {
            return nil }
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.size.width
        let height = view.bounds.size.height
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height

        switch screenHeight {
        case 550..<570:
            return CGSize(width: width - 80, height: height - 360)
        case 571..<670:
            return CGSize(width: width - 80, height: height - 480)
        case 671..<720:
            return CGSize(width: width - 80, height: height - 600)
        case 721..<750:
            return CGSize(width: width - 80, height: height - 550)
        default:
            return CGSize(width: width - 80, height: height - 630)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: weatherNavigationID, for: indexPath) as! WeatherCollectionViewCell
        let weather = weatherForecast
        let weatherTwo = weather[indexPath.item]
        let date = Calendar.current.date(byAdding: .day, value: indexPath.item, to: Date())
        if let time = date {
            cell.dateTime.text = dateFormatter.string(from: time)
        }
        cell.update(with: weatherTwo)
        cell.layer.cornerRadius = 20.0
        return cell
    }
}


