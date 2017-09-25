//
//  Utility.swift
//  BikeshareRidePlanner
//
//  Created by Akash Ungarala on 9/20/17.
//  Copyright © 2017 Akash Ungarala. All rights reserved.
//

import UIKit

struct Utility {
    
    enum RangeStatus {
        
        case origin
        case destination
        case none
        
    }
    
    enum Availability {
        
        case yes
        case no
        case none
        
    }
    
    enum DirectionsTitle: String {
        
        case origin = "Directions to here"
        case destination = "Directions from here"
        case none = "Directions to ..."
        
    }
    
    // Distance
    struct distance {
        
        static func convertToMiles(meters: Double) -> Double {
            return meters/(1609.34)
        }
        
    }
    
    // Colors
    struct color {
        
        static let grey = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
        static let red  = UIColor(red: 252/255, green: 98/255, blue: 99/255, alpha: 1)
        
    }
    
    // Url
    struct url {
        
        static let urlString = "http://www.bayareabikeshare.com/stations/json"
        static let url = URL(string: urlString)!
        
    }
    
    // Images
    struct image {
        
        static let bikeshareStation = "bikeshareStation"
        static let bikeAvailableBikeshareStation = "bikeAvailableBikeshareStation"
        static let bikeNotAvailableBikeshareStation = "bikeNotAvailableBikeshareStation"
        static let dockAvailableBikeshareStation = "dockAvailableBikeshareStation"
        static let dockNotAvailableBikeshareStation = "dockNotAvailableBikeshareStation"
        static let origin = "origin"
        static let destination = "destination"
        
        static func getImageView(_ name: String, width: Int, height: Int) -> UIImageView {
            let image = UIImageView(image: UIImage(named: name))
            var imageRect = image.frame as CGRect
            imageRect.size.width = CGFloat(width)
            imageRect.size.height = CGFloat(height)
            image.frame = imageRect
            return image
        }
        
    }
    
}
