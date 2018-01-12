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
    private let reachability = Reachability()!
    private let likelyPlaces: [GMSPlace] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
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
    
    @objc func internetChanged(note: NSNotification) {
        if let reachability = note.object as? Reachability {
            if reachability.connection == .wifi {
                print("Wifi")
            }
        }
    }
    
    @objc func timeToMoveOn() {
        DispatchQueue.main.async {
            self.moveOn()
        }
    }
    
    private func moveOn() {
        guard self.reachability.connection == .wifi || self.reachability.connection == .cellular else {
            presentAlert(title: "Online Connnection!", message: "Your mobile device is currently not online.")
            return
        }
        
        switch LocationService.shared.status {
        case .denied, .disabled:
        break // show alert saying "go to settings"
        case .notDetermined:
            // hopefully doesn't get here. should have determined by now!
            break
        case .authorised:
            performSegue(withIdentifier: "locationConfigID", sender: self)
        }
    }

    @IBAction func checkLocation(_ sender: Any) {
        self.moveOn()
    }
}
