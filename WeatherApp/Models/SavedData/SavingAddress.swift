//
//  SavingAddress.swift
//  WeatherApp
//
//  Created by Ade Adegoke on 18/12/2017.
//  Copyright © 2017 AKA. All rights reserved.
//
import CoreData
import UIKit
import Foundation

class SavingAddress {

    static let shared = SavingAddress()

    func savingAddressToCoreData(save: AddressWithCoordinate) {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        newLocation.setValue(save.address, forKey: "address")
        newLocation.setValue(save.coordinate.latitude, forKey: "latitude")
        newLocation.setValue(save.coordinate.longitude, forKey: "longitude")
        do {
        try context.save()
        } catch {
        }
    }
}
