//
//  AddressesSaved.swift
//  WeatherApp
//
//  Created by Ade Adegoke on 15/12/2017.
//  Copyright © 2017 AKA. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class AddressesSaved {
   
    static let shared = AddressesSaved()
    static let didUpdate: String = "CoreDataDidUpdateAddresses"
    
    private var addresses = [String]()
  
    private var address = [AddressWithCoordinate]()
    
    
    func addressesFromCoreData() -> [AddressWithCoordinate] {
        
        if address.isEmpty {
            address = loadAddressesFromCoreData()
        }
        return address
    }


    private func loadAddressesFromCoreData() -> [AddressWithCoordinate] {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        var loadedaddress = [AddressWithCoordinate]()

        do {

            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
            let results = try context.fetch(request)
            if results.count > 0 {
                for item in results as! [NSManagedObject] {
                    if let address = item.value(forKey: "address") as? String, let latitude = item.value(forKey: "latitude") as? Double, let longitude = item.value(forKey: "longitude") as? Double {
                        let coordinate: Coordinate = (latitude, longitude)
                        let addressWithCoordinate = (address, coordinate)
                        self.address.insert(addressWithCoordinate, at: 0)
                        loadedaddress.insert((addressWithCoordinate), at: 0)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AddressesSaved.didUpdate), object: self)
                    }
                }
            }
        } catch {
            print("there are issues")
        }
        return loadedaddress
    }
}
