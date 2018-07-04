//
//  Pokemon+CoreDataProperties.swift
//  Pokédex
//
//  Created by Juliana on 03/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//
//

import Foundation
import CoreData


extension Pokemon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pokemon> {
        return NSFetchRequest<Pokemon>(entityName: "Pokemon")
    }

    @NSManaged public var height: Int16
    @NSManaged public var id: Int16
    @NSManaged public var indexes: [String: Int]?
    @NSManaged public var name: String?
    @NSManaged public var weight: Int16
    @NSManaged public var types: NSSet?

}

// MARK: Generated accessors for types
extension Pokemon {

    @objc(addTypesObject:)
    @NSManaged public func addToTypes(_ value: Type)

    @objc(removeTypesObject:)
    @NSManaged public func removeFromTypes(_ value: Type)

    @objc(addTypes:)
    @NSManaged public func addToTypes(_ values: NSSet)

    @objc(removeTypes:)
    @NSManaged public func removeFromTypes(_ values: NSSet)

}
