//
//  AuthService.swift
//  BikeshareRidePlanner
//
//  Created by Akash Ungarala on 9/23/17.
//  Copyright © 2017 Akash Ungarala. All rights reserved.
//

import UIKit

class AuthService: NSObject {
    
    static let sharedInstance = AuthService()
    
    func fetchBikeshareStations(completion: @escaping ([BikeshareStationAnnotation]?) -> ()) {
        URLSession.shared.dataTask(with: URLRequest(url: Utility.url.url), completionHandler: { data, response, error in
            if error == nil && data != nil {
                do {
                    if let results = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary {
                        if let stations = results["stationBeanList"] as? [NSDictionary] {
                            var bikeshareStationAnnotations = [BikeshareStationAnnotation]()
                            for station in stations {
                                if let bikeshareStation = self.fetchBikeshareStation(station: station) {
                                    bikeshareStationAnnotations.append(bikeshareStation.fetchAnnotation())
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                completion(bikeshareStationAnnotations)
                            })
                        } else {
                            completion(nil)
                        }
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }).resume()
    }
    
    func fetchBikeshareStation(station: NSDictionary) -> BikeshareStation? {
        let bikeshareStation = BikeshareStation()
        if let id = station["id"] as? Int {
            bikeshareStation.id = id
        }
        if let stationName = station["stationName"] as? String {
            bikeshareStation.stationName = stationName
        }
        if let availableDocks = station["availableDocks"] as? Int {
            bikeshareStation.availableDocks = availableDocks
        }
        if let totalDocks = station["totalDocks"] as? Int {
            bikeshareStation.totalDocks = totalDocks
        }
        if let latitude = station["latitude"] as? Double {
            bikeshareStation.latitude = latitude
        }
        if let longitude = station["longitude"] as? Double {
            bikeshareStation.longitude = longitude
        }
        if let statusValue = station["statusValue"] as? String {
            bikeshareStation.statusValue = statusValue
        }
        if let statusKey = station["statusKey"] as? Int {
            bikeshareStation.statusKey = statusKey
        }
        if let availableBikes = station["availableBikes"] as? Int {
            bikeshareStation.availableBikes = availableBikes
        }
        if let stAddress1 = station["stAddress1"] as? String {
            bikeshareStation.stAddress1 = stAddress1
        }
        return bikeshareStation
    }
    
}
