//
//  GetLocationTask.swift
//  Overdrive
//
//  Created by Said Sikira on 6/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import CoreLocation

public class GetLocationTask: Task<CLLocation>, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    public override func run() {
        Dispatch.async(dispatch_get_main_queue()) {
            self.manager.delegate = self
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.startUpdatingLocation()
        }
    }
    
    @objc public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            finish(.Value(location))

        }
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        finish(.Error(error))
    }
}
