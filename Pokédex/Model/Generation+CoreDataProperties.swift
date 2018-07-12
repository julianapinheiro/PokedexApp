//
//  Generation+CoreDataProperties.swift
//  Pokédex
//
//  Created by Juliana on 12/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//
//

import Foundation
import CoreData


extension Generation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Generation> {
        return NSFetchRequest<Generation>(entityName: "Generation")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: Int16
    @NSManaged public var pokemonList: NSSet?

}

// MARK: Generated accessors for pokemonList
extension Generation {

    @objc(addPokemonListObject:)
    @NSManaged public func addToPokemonList(_ value: PokemonId)

    @objc(removePokemonListObject:)
    @NSManaged public func removeFromPokemonList(_ value: PokemonId)

    @objc(addPokemonList:)
    @NSManaged public func addToPokemonList(_ values: NSSet)

    @objc(removePokemonList:)
    @NSManaged public func removeFromPokemonList(_ values: NSSet)

}
