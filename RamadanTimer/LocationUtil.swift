//
//  LocationUtil.swift
//  RamadanTimer
//
//  Created by Sumayyah on 23/11/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import Foundation
import CoreLocation

/**
 Manages location settings
 */
class LocationUtil: NSObject, CLLocationManagerDelegate {
    
    /// shared instance
    static let shared = LocationUtil()
    /// location manager
    let locationManager = CLLocationManager()
    /// location coordinates
    var location : (lat: Double, long: Double) = (0,0)
    /// location name
    var locationName: String = ""
    var locationSet = false
    /// delegate
    var delegate: LocationDelegate!

    /// set up location
    func setUpLocation() {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        if UserSettings.shared.autoLocation {
            // auto location
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
        else {
            getSavedLocation()
            self.delegate.locationUpdated()
            self.locationSet = true
        }
    }
    
    // MARK: Location manager delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get 2d coordinates
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        location = (locValue.latitude, locValue.longitude)
        // Display city and country
        locationNameFromCoordinates(location: manager.location!, completion: {
            address in
            self.locationName = address 
            self.delegate.locationUpdated()
            self.locationSet = true
        })
        saveNewLocation()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        getSavedLocation()
        self.delegate.locationUpdated()
        self.locationSet = true
    }
    
    /// save location to user defaults
    func saveNewLocation() {
        UserDefaults.standard.set(location.lat, forKey: "latitude")
        UserDefaults.standard.set(location.long, forKey: "longitude")
        UserDefaults.standard.set(locationName, forKey: "locationName")
    }
    
    /// get saved location from user defaults
    func getSavedLocation() {
        let savedLocation = (UserDefaults.standard.double(forKey: "latitude"), UserDefaults.standard.double(forKey: "longitude"))
        // location default set to Makkah
        location = savedLocation == (0,0) ? (21.42667, 39.82611) : savedLocation
        locationName = UserDefaults.standard.string(forKey: "locationName") ?? "Makkah, Saudi Arabia"
    }
}

protocol LocationDelegate {
    func locationUpdated()
}
