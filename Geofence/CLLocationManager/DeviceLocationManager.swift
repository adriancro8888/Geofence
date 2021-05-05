import Foundation
import CoreLocation

public class DeviceLocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Private Properties
    
    /// Internal device comunication object.
    private var manager: CLLocationManager
    
    /// Delegate of events.
    public var delegate: LocationManagerDelegate?
    
    // MARK: - Public Properties

    /// The status of the authorization manager.
    public var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return manager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    public var allowsBackgroundLocationUpdates: Bool {
        set { manager.allowsBackgroundLocationUpdates = newValue }
        get { manager.allowsBackgroundLocationUpdates }
    }
    
    public var pausesLocationUpdatesAutomatically: Bool {
        set { manager.pausesLocationUpdatesAutomatically = newValue }
        get { manager.pausesLocationUpdatesAutomatically }
    }
    
    // MARK: - Initialization

    init(locationManager : CLLocationManager) {
        self.manager = locationManager
        super.init()
        self.manager.delegate = self
    }
    
    public var monitoredRegions: Set<CLRegion> {
        manager.monitoredRegions
    }
    
    public func requestAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    /// Check for precise location authorization
    /// If user hasn't given it, ask for one time permission
    public func checkAndRequestForAccuracyAuthorizationIfNeeded(_ completion: ((Bool) -> Void)?) {
        if #available(iOS 14.0, *) {
            guard manager.accuracyAuthorization != .fullAccuracy else {
                completion?(true)
                return
            }
            manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "OneTimeLocation") { [weak self] (error) in
                self?.manager.accuracyAuthorization == .fullAccuracy ? completion?(true) : completion?(false)
            }
        } else {
            // Ignore for any system below iOS 14+
            completion?(true)
        }
    }

    /// Replace [CLRegion] by GeofencingRequest in the future. Those requests use to call API
    
    public func geofenceRegions(_ requests: [CLRegion], isMonitoringAvailable : Bool) {
        // If region monitoring is not supported for this device just cancel all monitoring by dispatching `.notSupported`.
        let isMonitoringSupported = isMonitoringAvailable
        if !isMonitoringSupported {
            delegate?.locationManager(geofenceError: .notSupported, region: nil)
            return
        }
        let regionToStopMonitoring = requests
        
        regionToStopMonitoring.forEach { [weak self] in
            self?.manager.stopMonitoring(for: $0)
        }

        requests.forEach { [weak self] in
            self?.manager.startMonitoring(for: $0)
        }
    }
    
    // MARK: - Private Functions
    
    private func didChangeAuthorizationStatus(_ newStatus: CLAuthorizationStatus) {
        guard newStatus != .notDetermined else {
            return
        }

    }
    
    // MARK: - CLLocationManagerDelegate (Location GPS)
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            didChangeAuthorizationStatus(manager.authorizationStatus)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // This method is called only on iOS 13 or lower, for iOS14 we are using `locationManagerDidChangeAuthorization` below.
        didChangeAuthorizationStatus(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(didFailWithError: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(didReceiveLocations: locations)
    }
    
    // MARK: - CLLocationManagerDelegate (Geofencing)
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.locationManager(geofenceEvent: .didEnteredRegion(region))
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.locationManager(geofenceEvent: .didExitedRegion(region))
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        delegate?.locationManager(geofenceError: .generic(error), region: region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        delegate?.locationManager(didVisits: visit)
    }
    
}


// MARK: - GeofenceEvent

/// The event produced by the request.
/// - `didEntered`: called when device entered into observed region.
/// - `didExited`: called when device exited from observed region.
/// - `didEnteredPolygon`: called when device entered inside the observer polygon.
/// - `didExitedPolygon`: called when device exited from the observer polygon.
public enum GeofenceEvent: CustomStringConvertible {
    case didEnteredRegion(CLRegion)
    case didExitedRegion(CLRegion)

    /// Description of the event.
    public var description: String {
        switch self {
        case .didEnteredRegion(let region):         return "Entered CircularRegion '\(region.description)'"
        case .didExitedRegion(let region):          return "Exited CircularRegion '\(region.description)'"
        }
    }

    /// Region monitored.
    public var region: CLRegion {
        switch self {
        case .didEnteredRegion(let r):       return r
        case .didExitedRegion(let r):        return r
        }
    }

    /// `true` if it's an enter event.
    public var isEntered: Bool {
        switch self {
        case .didEnteredRegion:   return true
        case .didExitedRegion:     return false
        }
    }

    /// `true` if it's an exit event.
    public var isExited: Bool {
        switch self {
        case .didEnteredRegion:   return false
        case .didExitedRegion:     return true
        }
    }

}


public enum LocationError: LocalizedError, Equatable {
    case generic(Error)
    case internalError
    case notSupported

    // MARK: - Public variables

    /// Localized error description.
    public var errorDescription: String? {
        switch self {
        case .generic(let e):       return e.localizedDescription
        case .internalError:        return "Internal Server Error"
        case .notSupported:         return "Not Supported"
        }
    }

    public static func == (lhs: LocationError, rhs: LocationError) -> Bool {
        switch (lhs, rhs) {
        case (.generic(let e1), .generic(let e2)):      return e1.localizedDescription == e2.localizedDescription
        case (.notSupported, .notSupported):            return true
        default:                                        return false
        }
    }

}
