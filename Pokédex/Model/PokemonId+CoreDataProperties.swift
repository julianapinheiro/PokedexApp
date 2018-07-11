//
//  PokemonId+CoreDataProperties.swift
//  Pokédex
//
//  Created by Juliana on 11/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//
//

import Foundation
import CoreData


extension PokemonId {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonId> {
        return NSFetchRequest<PokemonId>(entityName: "PokemonId")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var pokemonInfo: Pokemon?
    @NSManaged public var types: NSSet?

}

// MARK: Generated accessors for types
extension PokemonId {

    @objc(addTypesObject:)
    @NSManaged public func addToTypes(_ value: Type)

    @objc(removeTypesObject:)
    @NSManaged public func removeFromTypes(_ value: Type)

    @objc(addTypes:)
    @NSManaged public func addToTypes(_ values: NSSet)

    @objc(removeTypes:)
    @NSManaged public func removeFromTypes(_ values: NSSet)

}
