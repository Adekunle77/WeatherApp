//
//  SavedAddresses.swift
//  WeatherApp
//
//  Created by Ade Adegoke on 15/12/2017.
//  Copyright © 2017 AKA. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SavedAddresses {
   
    static let shared = SavedAddresses()
    static let didUpdate: String = "CoreDataDidUpdateAddresses"
    
    private var addresses = [String]()
    
    func addressesFromCoreData() -> [String] {
        if addresses.isEmpty {
           addresses = loadAddressesFromCoreData()
        
        } else {
            addresses[0] = "No saved searches"
            addresses[1] = "No saved searches"
        }
        return addresses
    }
    
    private func loadAddressesFromCoreData() -> [String] {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        var loadedaddresses = [String]()
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
            let results = try context.fetch(request)
            if results.count > 0 {
                for item in results as! [NSManagedObject] {
                    if let name = item.value(forKey: "address") as? String {
                        self.addresses.insert(name, at: 0)
                        loadedaddresses.append(name)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SavedAddresses.didUpdate), object: self)
                    }
                }
            }
        } catch {
            print("there are issues")
        }
        return loadedaddresses 
    }
}
