//
//  MockLocationManager.swift
//  GeofenceTests
//
//  Created by Thoms Woodfin on 5/5/21.
//

import CoreLocation

class MockLocationManager: CLLocationManager {

    static let shared = MockLocationManager()
    static var isMonitoringAvailable : Bool = true

    var mockLocation: CLLocation?
    var mockAccuracyAuthorization : CLAccuracyAuthorization?

    override var location: CLLocation? {
        return mockLocation
    }

    override var accuracyAuthorization: CLAccuracyAuthorization {
        return mockAccuracyAuthorization!
    }

    override class func isMonitoringAvailable(for regionClass: AnyClass) -> Bool {
        return isMonitoringAvailable
    }
}
