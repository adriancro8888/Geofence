//
//  DeviceLocationManagerTests.swift
//  GeofenceTests
//
//  Created by Thoms Woodfin on 5/5/21.
//

import XCTest
import CoreLocation

class DeviceLocationManagerTests: XCTestCase {

    override func setUpWithError() throws {
        MockLocationManager.shared.mockLocation = CLLocation(latitude: 37.3349285, longitude: -122.011033)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        MockLocationManager.shared.mockLocation = nil
    }

    func testCheckAndRequestForAccuracyAuthorizationIfNeededWith_FullAccuracy() throws {
        let deviceLocationManager = DeviceLocationManager(locationManager: MockLocationManager.shared)
        MockLocationManager.shared.mockAccuracyAuthorization = .fullAccuracy
        deviceLocationManager.checkAndRequestForAccuracyAuthorizationIfNeeded { (accuracyAuthorization) in
            XCTAssertTrue(accuracyAuthorization)
        }
    }

    func testCheckAndRequestForAccuracyAuthorizationIfNeededWith_NotFullAccuracy() throws {
        let deviceLocationManager = DeviceLocationManager(locationManager: MockLocationManager.shared)
        MockLocationManager.shared.mockAccuracyAuthorization = .reducedAccuracy
        deviceLocationManager.checkAndRequestForAccuracyAuthorizationIfNeeded { (accuracyAuthorization) in
            XCTAssertFalse(accuracyAuthorization)
        }
    }

    func testGeofenceRegions_IsNotMonitoringAvailable() throws {
        MockLocationManager.isMonitoringAvailable = false
        let deviceLocationManager = DeviceLocationManager(locationManager: MockLocationManager.shared)
        let locationManagerDelegate = TestLocationManagerDelegate()
        let asyncExpectation = expectation(description: "IsNotMonitoringAvailable")
        locationManagerDelegate.asyncExpectation = asyncExpectation
        deviceLocationManager.delegate = locationManagerDelegate
        let coordinate = CLLocationCoordinate2DMake(37.3349285, -122.011033)
        let regionRadius = 300.0
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
            longitude: coordinate.longitude), radius: regionRadius, identifier: "Mock_ID_01")
        deviceLocationManager.geofenceRegions([region], isMonitoringAvailable: MockLocationManager.isMonitoringAvailable(for: CLCircularRegion.self))
        waitForExpectations(timeout: 10) { error in
            if let error = error {
              XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let result = locationManagerDelegate.geofenceError else {
              XCTFail("Expected delegate to be called")
              return
            }
            XCTAssertEqual(result, LocationError.notSupported)
        }
    }

    func testLocationManager_DidFailWithError() throws {
        MockLocationManager.isMonitoringAvailable = false
        let deviceLocationManager = DeviceLocationManager(locationManager: MockLocationManager.shared)
        let locationManagerDelegate = TestLocationManagerDelegate()
        let asyncExpectation = expectation(description: "DidFailWithError")
        locationManagerDelegate.asyncExpectation = asyncExpectation
        deviceLocationManager.delegate = locationManagerDelegate
        MockLocationManager.shared.delegate?.locationManager?(MockLocationManager.shared, didFailWithError: NSError(domain: "DidFailWithError", code: 10001, userInfo: nil))
        waitForExpectations(timeout: 10) { error in
            if let error = error {
              XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let error = locationManagerDelegate.didFailWithError else {
              XCTFail("Expected delegate to be called")
              return
            }
            XCTAssertEqual((error as NSError).domain, "DidFailWithError")
        }
    }

    func testLocationManager_didUpdateLocations() throws {
        MockLocationManager.isMonitoringAvailable = false
        let deviceLocationManager = DeviceLocationManager(locationManager: MockLocationManager.shared)
        let locationManagerDelegate = TestLocationManagerDelegate()
        let asyncExpectation = expectation(description: "didUpdateLocations")
        locationManagerDelegate.asyncExpectation = asyncExpectation
        deviceLocationManager.delegate = locationManagerDelegate
        MockLocationManager.shared.delegate?.locationManager?(MockLocationManager.shared, didUpdateLocations: [CLLocation(latitude: 37.3349285, longitude: -122.011033)])
        waitForExpectations(timeout: 10) { error in
            if let error = error {
              XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let locations = locationManagerDelegate.didReceiveLocations else {
              XCTFail("Expected delegate to be called")
              return
            }
            XCTAssertEqual(locations.first?.coordinate.latitude, 37.3349285)
        }
    }

    func testLocationManager_didEnterRegion() throws {
        MockLocationManager.isMonitoringAvailable = false
        let deviceLocationManager = DeviceLocationManager(locationManager: MockLocationManager.shared)
        let locationManagerDelegate = TestLocationManagerDelegate()
        let asyncExpectation = expectation(description: "didEnterRegion")
        locationManagerDelegate.asyncExpectation = asyncExpectation
        deviceLocationManager.delegate = locationManagerDelegate
        let title = "Apple"
        let coordinate = CLLocationCoordinate2DMake(37.3349285, -122.011033)
        let regionRadius = 300.0
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
            longitude: coordinate.longitude), radius: regionRadius, identifier: title)
        MockLocationManager.shared.delegate?.locationManager?(MockLocationManager.shared, didEnterRegion: region)
        waitForExpectations(timeout: 10) { error in
            if let error = error {
              XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let geofenceEvent = locationManagerDelegate.geofenceEvent else {
              XCTFail("Expected delegate to be called")
              return
            }
            switch geofenceEvent {
            case .didEnteredRegion(let region):
                debugPrint("didEnteredRegion \(region)")
                if let circleRegion = region as? CLCircularRegion {
                    XCTAssertEqual(circleRegion.center.latitude, 37.3349285)
                    XCTAssertEqual(circleRegion.radius, 300.0)
                }
            case .didExitedRegion(let region):
                debugPrint("didExitedRegion \(region)")
            }
        }
    }

}
