//
//  WeatherButton.swift
//  TheWeatherApp
//
//  Created by Ade Adegoke on 14/10/2017.
//  Copyright © 2017 Ade Adegoke. All rights reserved.
//

import UIKit

class WeatherButton: UIButton {
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)

        let path = UIBezierPath()

        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 1.0

        UIColor.white.setStroke()
        path.stroke()
    }
}
