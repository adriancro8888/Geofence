//
//  LocationManagerDelegate.swift
//  GeofenceTests
//
//  Created by Thoms Woodfin on 5/6/21.
//
import CoreLocation
import XCTest

class TestLocationManagerDelegate: LocationManagerDelegate {

    /// Location manager error
    var didFailWithError: Error? = .none
    /// Location manage did receive locations
    var didReceiveLocations : [CLLocation]? = .none
    var geofenceEvent : GeofenceEvent? = .none
    var clVisit : CLVisit? = .none
    var geofenceError : LocationError? = .none
    var region : CLRegion? = .none
    /// Async test code needs to fulfill the XCTestExpecation used for the test
    /// when all the async operations have been completed. For this reason we need
    /// to store a reference to the expectation
    var asyncExpectation: XCTestExpectation?

    func locationManager(didFailWithError error: Error) {
        guard let expectation = asyncExpectation else {
            XCTFail("TestLocationManagerDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        didFailWithError = error
        expectation.fulfill()
    }

    func locationManager(didReceiveLocations locations: [CLLocation]) {
        guard let expectation = asyncExpectation else {
            XCTFail("TestLocationManagerDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        didReceiveLocations = locations
        expectation.fulfill()
    }

    func locationManager(geofenceEvent event: GeofenceEvent) {
        guard let expectation = asyncExpectation else {
            XCTFail("TestLocationManagerDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        geofenceEvent = event
        expectation.fulfill()
    }

    func locationManager(geofenceError error: LocationError, region: CLRegion?) {
        guard let expectation = asyncExpectation else {
            XCTFail("TestLocationManagerDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        geofenceError = error
        self.region = region
        expectation.fulfill()
    }

    func locationManager(didVisits visit: CLVisit) {
        guard let expectation = asyncExpectation else {
            XCTFail("TestLocationManagerDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        clVisit = visit
        expectation.fulfill()
    }
    

}
