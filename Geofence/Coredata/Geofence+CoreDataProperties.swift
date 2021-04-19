//
//  Geofence+CoreDataProperties.swift
//  Geofence
//
//  Created by Thoms Woodfin on 4/20/21.
//
//

import Foundation
import CoreData


extension Geofence {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Geofence> {
        return NSFetchRequest<Geofence>(entityName: "Geofence")
    }

    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var isEnter: Bool

}

extension Geofence : Identifiable {

}
