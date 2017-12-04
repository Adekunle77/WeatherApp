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
    private let userManger = CLLocationManager()
    private let gradientLayer = CAGradientLayer()
    private var weatherForecast = [WeathersModel]()
    private var dateNTime = Timer()
    private var locationFromSearchBar = "New York"
    private var enteredLatLong: String?
    private var savedSearches = [String]()
    private var currentLat: String = ""
    private var currentLong: String = ""
    
    public var userLatitude: String?
    public var userLongitude: String?
    public var usersLocation: String?
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        
        savedData()
        getLatLong(latLongAddressFromUser: locationFromSearchBar)

        // Set up for getting the current users location
        userManger.delegate = self
        userManger.desiredAccuracy = kCLLocationAccuracyBest
        userManger.requestWhenInUseAuthorization()
        userManger.startUpdatingLocation()

        // collectionview setup
        let nib = UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: weatherNavigationID)
        collectionView.allowsSelection = false
        collectionView.isPagingEnabled = true
        
        searchButton.backgroundColor = UIColor.weatherBlue
        searchButton.layer.cornerRadius = 6.0
    
        gradientLayer.frame = self.view.frame
        gradientLayer.colors = [UIColor.weatherLightBlue.cgColor, UIColor.weatherDarkBlue.cgColor]
       //  setting the background view with google maps
        let camera = GMSCameraPosition.camera(withLatitude: Double(self.userLatitude!)!, longitude: Double(self.userLongitude!)!, zoom: 15.0)
        let marker = GMSMarker()
        marker.position = camera.target

        marker.map = self.backgroundView
        self.backgroundView.moveCamera(GMSCameraUpdate.setCamera(camera))
    }

    func savedData() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext

        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
            let results = try context.fetch(request)

            if results.count > 0 {
                for item in results as! [NSManagedObject] {
                    let name = item.value(forKey: "address")
                    savedSearches.insert(name as! String, at: 0)
                }
            }
        } catch {
            print("there are issues")
        }
    }

    func getLatLong(latLongAddressFromUser: String) {
        var latLong: String?
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(latLongAddressFromUser) { (placemarks, _) in
            guard let placemark = placemarks?.first?.location else {return}
            let lat = String(placemark.coordinate.latitude)
            let long = String(placemark.coordinate.longitude)
            latLong = lat + " " + long
            if latLong != nil {
            self.enteredLatLong = latLong
            }
        }
    }
    @IBAction func searchAgain(_ sender: UIButton) {
        self.performSegue(withIdentifier: "searchAgainSegueID", sender: self)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        // Converting the above latitude & longitude into a string.
        self.currentLat = String(location.coordinate.latitude)
        self.currentLong = String(location.coordinate.longitude)

        WeatherManager.shared.weatherFromJsonUrl(withLocation: self.usersLocation!) {(results: [WeathersModel]?) in
            if let fetachedWeather = results {
                self.weatherForecast = fetachedWeather
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                  self.userManger.stopUpdatingLocation()
                }
            }
        }
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
        let screenWidth = Int(screenSize.width)
        let screenHeight = screenSize.height
        
        print(screenWidth, screenHeight)
        
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
        
        cell.dateTime.text = dateFormatter.string(from: date!)
        cell.update(with: weatherTwo)
        cell.layer.cornerRadius = 20.0
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchAgainSegueID" {
            let searchAgainVC: EnterLocationViewController = segue.destination as! EnterLocationViewController
            searchAgainVC.userLatitude = currentLat
            searchAgainVC.userLongitude = currentLong
            searchAgainVC.revievedSavedLocation = self.savedSearches
        }
    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor
        self.addSublayer(border)
    }
}

