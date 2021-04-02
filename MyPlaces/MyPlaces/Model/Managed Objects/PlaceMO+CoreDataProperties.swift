//
//  PlaceMO+CoreDataProperties.swift
//  MyPlaces
//
//  Created by Paul Bonneville on 4/1/21.
//
//

import Foundation
import CoreData


extension PlaceMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaceMO> {
        return NSFetchRequest<PlaceMO>(entityName: "Place")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var type: String?
    @NSManaged public var imageData: Data?

}

extension PlaceMO : Identifiable {

}
