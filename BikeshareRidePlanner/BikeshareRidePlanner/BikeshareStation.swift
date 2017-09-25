//
//  BikeshareStation.swift
//  BikeshareRidePlanner
//
//  Created by Akash Ungarala on 9/19/17.
//  Copyright © 2017 Akash Ungarala. All rights reserved.
//

import Foundation

class BikeshareStation: NSObject {
    
    var annotationHash: Int!
    var id: Int!
    var stationName: String!
    var availableDocks: Int!
    var totalDocks: Int!
    var latitude: Double!
    var longitude: Double!
    var statusValue: String!
    var statusKey: Int!
    var availableBikes: Int!
    var stAddress1: String!
    
    func fetchAnnotation() -> BikeshareStationAnnotation {
        let annotation = BikeshareStationAnnotation()
        annotation.bikeshareStation = self
        annotation.rangeStatus = Utility.RangeStatus.none
        if let availableBikes = self.availableBikes {
            annotation.updateBikeAvailability(availableBikes)
        }
        if let availableDocks = self.availableDocks {
            annotation.updateDockAvailability(availableDocks)
        }
        return annotation
    }
    
}
