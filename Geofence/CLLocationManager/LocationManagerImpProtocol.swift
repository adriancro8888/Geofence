import Foundation
import CoreLocation

// MARK: - LocationManagerDelegate

public protocol LocationManagerDelegate: class {
    
    // MARK: - Location Manager
    func locationManager(didFailWithError error: Error)
    func locationManager(didReceiveLocations locations: [CLLocation])
    
    // MARK: - Geofencing
    func locationManager(geofenceEvent event: GeofenceEvent)
    func locationManager(geofenceError error: LocationError, region: CLRegion?)
    
    // MARK: - Visits
    func locationManager(didVisits visit: CLVisit)

}
