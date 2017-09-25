//
//  BikeshareStationAnnotation.swift
//  BikeshareRidePlanner
//
//  Created by Akash Ungarala on 9/20/17.
//  Copyright © 2017 Akash Ungarala. All rights reserved.
//

import MapKit

class BikeshareStationAnnotation: MKPointAnnotation {
    
    var rangeStatus: Utility.RangeStatus!
    var bikeAvailability: Utility.Availability!
    var dockAvailability: Utility.Availability!

    var bikeshareStation: BikeshareStation! {
        didSet {
            if let latitude = bikeshareStation.latitude, let longitude = bikeshareStation.longitude {
                self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                if let address = bikeshareStation.stAddress1 {
                    self.title = address
                }
            }
        }
    }
    
    func updateRangeStatus(originAnnotation: MKPointAnnotation, destinationAnnotation: MKPointAnnotation, distance: Float) {
        let annotationLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        let originLocation = CLLocation(latitude: originAnnotation.coordinate.latitude, longitude: originAnnotation.coordinate.longitude)
        let destinationLocation = CLLocation(latitude: destinationAnnotation.coordinate.latitude, longitude: destinationAnnotation.coordinate.longitude)
        let distanceFromOrigin = Utility.distance.convertToMiles(meters: originLocation.distance(from: annotationLocation))
        let distanceFromDestination = Utility.distance.convertToMiles(meters: destinationLocation.distance(from: annotationLocation))
        let stationDistance = Double(distance)
        if distanceFromOrigin < stationDistance {
            if distanceFromDestination < distanceFromOrigin {
                rangeStatus = Utility.RangeStatus.destination
            } else {
                rangeStatus = Utility.RangeStatus.origin
            }
        } else if distanceFromDestination < stationDistance {
            rangeStatus = Utility.RangeStatus.destination
        } else {
            rangeStatus = Utility.RangeStatus.none
        }
    }
    
    func updateBikeAvailability(_ availableBikes: Int) {
        bikeAvailability = (availableBikes > 0) ? Utility.Availability.yes : Utility.Availability.no
    }
    
    func updateDockAvailability(_ availableDocks: Int) {
        dockAvailability = (availableDocks > 0) ? Utility.Availability.yes : Utility.Availability.no
    }
    
    func getDirectionsTitle() -> String {
        var directionsTitle = Utility.DirectionsTitle.none.rawValue
        if rangeStatus == .origin {
            directionsTitle = Utility.DirectionsTitle.origin.rawValue
        } else if rangeStatus == .destination {
            directionsTitle = Utility.DirectionsTitle.destination.rawValue
        }
        return directionsTitle
    }
    
    func getImageName() -> String {
        var imageName = Utility.image.bikeshareStation
        if rangeStatus == .origin {
            if bikeAvailability == .yes {
                imageName = Utility.image.bikeAvailableBikeshareStation
            } else if bikeAvailability == .no {
                imageName = Utility.image.bikeNotAvailableBikeshareStation
            }
        } else if rangeStatus == .destination {
            if dockAvailability == .yes {
                imageName = Utility.image.dockAvailableBikeshareStation
            } else if dockAvailability == .no {
                imageName = Utility.image.dockNotAvailableBikeshareStation
            }
        }
        return imageName
    }
    
    func openInMaps() {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = bikeshareStation.stationName
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func openInMaps(from: MKPointAnnotation) {
        let fromPlacemark = MKPlacemark(coordinate: from.coordinate)
        let fromMapItem = MKMapItem(placemark: fromPlacemark)
        fromMapItem.name = from.title
        let toPlacemark = MKPlacemark(coordinate: coordinate)
        let toMapItem = MKMapItem(placemark: toPlacemark)
        toMapItem.name = bikeshareStation.stationName
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        MKMapItem.openMaps(with: [fromMapItem, toMapItem], launchOptions: launchOptions)
    }
    
    func openInMaps(to: MKPointAnnotation) {
        let fromPlacemark = MKPlacemark(coordinate: coordinate)
        let fromMapItem = MKMapItem(placemark: fromPlacemark)
        fromMapItem.name = bikeshareStation.stationName
        let toPlacemark = MKPlacemark(coordinate: to.coordinate)
        let toMapItem = MKMapItem(placemark: toPlacemark)
        toMapItem.name = to.title
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        MKMapItem.openMaps(with: [fromMapItem, toMapItem], launchOptions: launchOptions)
    }
    
}
