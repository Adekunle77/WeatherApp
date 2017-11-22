//
//  TABUIColors.swift
//  Marvel
//
//  Created by Ade Adegoke on 18/07/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//

import UIKit

extension UIColor {
    static let weatherBlue = UIColor(hex: 0x298EE0)
    static let weatherDarkBlue = UIColor(hex: 0x375D7C)
    static let weatherLightBlue = UIColor(hex: 0x6A9FE8)
    static let weatherPurple = UIColor(hex: 0x6C5C7A)
    static let weatherRed = UIColor(hex: 0xF47382)
    static let weatherCream  = UIColor(hex: 0xF6B197)

    convenience init(red: Int, green: Int, blue: Int, alp: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alp
        )
}

    convenience init (hex: Int, alp: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            alp: alp
            
        )
        
    }
}
