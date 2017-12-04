//
//  WeatherCollectionViewCell.swift
//  TheWeatherApp
//
//  Created by Ade Adegoke on 03/08/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//

import Foundation
import UIKit


class WeatherCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak  var summaryLabel: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var temperatureLabel: UILabel!
    @IBOutlet weak private var cellBackgroundView: WeatherCollectionViewCell!

 //  var weatherFromJSON: WeatherSModel?
   // var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.weatherBlue
    }
    
    func update(with weatherFromJSON: WeathersModel) {
        summaryLabel.text = weatherFromJSON.summary
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formattedAmount = formatter.string(from: weatherFromJSON.temperatureMax as NSNumber)!
        temperatureLabel.text = String(formattedAmount)
        iconImage.image = UIImage(named: weatherFromJSON.icon)
    }

//    func update(with weatherFromJSON: WeatherModel) {
//        summaryLabel.text = weatherFromJSON.summary
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.maximumFractionDigits = 0
//        let formattedAmount = formatter.string(from: weatherFromJSON.temperature as NSNumber)!
//        temperatureLabel.text = String(formattedAmount)
//        iconImage.image = UIImage(named: weatherFromJSON.icon)
//    }
}
