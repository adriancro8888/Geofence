//
//  ViewController.swift
//  Geofence
//
//  Created by Thoms Woodfin on 4/20/21.
//

import UIKit
import MapKit
import CoreData

class GeofenceViewController: UIViewController {

    let deviceLocationManager = DeviceLocationManager(locationManager: CLLocationManager())

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onGeofenceClicked(_ sender : UIButton) {
        deviceLocationManager.requestAuthorization()
        if let regions = simulatedRegions() {
            deviceLocationManager.delegate = self
            deviceLocationManager.geofenceRegions(regions, isMonitoringAvailable: CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self))
        }
    }

    // MARK: Helper methods

    func simulatedRegions() -> [CLRegion]? {

        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let title = "Apple"
            let coordinate = CLLocationCoordinate2DMake(37.3349285, -122.011033)
            let regionRadius = 300.0
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                longitude: coordinate.longitude), radius: regionRadius, identifier: title)
            return [region]
        }
        return nil
    }

    private func saveGeofenceWithEvent(_ region : CLCircularRegion, isEnter : Bool) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Geofence", in: managedContext)!
        let geofence = NSManagedObject(entity: entity, insertInto: managedContext)
        geofence.setValue(region.center.latitude, forKeyPath: "lat")
        geofence.setValue(region.center.longitude, forKeyPath: "lon")
        geofence.setValue(isEnter, forKeyPath: "isEnter")
        do {
            try managedContext.save()
        } catch let error as NSError {
            debugPrint("Failed to save. \(error), \(error.userInfo)")
        }
    }

}

extension GeofenceViewController : LocationManagerDelegate {

    func locationManager(didFailWithError error: Error) {
        debugPrint(#function)
    }

    func locationManager(didReceiveLocations locations: [CLLocation]) {
        debugPrint(#function)
    }

    func locationManager(geofenceEvent event: GeofenceEvent) {
        debugPrint(#function)
        switch event {
        case .didEnteredRegion(let region):
            debugPrint("didEnteredRegion \(region)")
            if let circleRegion = region as? CLCircularRegion {
                saveGeofenceWithEvent(circleRegion, isEnter: true)
            }
        case .didExitedRegion(let region):
            debugPrint("didExitedRegion \(region)")
            if let circleRegion = region as? CLCircularRegion {
                saveGeofenceWithEvent(circleRegion, isEnter: false)
            }
        }
    }

    func locationManager(geofenceError error: LocationError, region: CLRegion?) {
        debugPrint(#function)
    }

    func locationManager(didVisits visit: CLVisit) {
        debugPrint(#function)
    }
}

