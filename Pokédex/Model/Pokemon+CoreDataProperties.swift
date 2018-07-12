//
//  Pokemon+CoreDataProperties.swift
//  Pokédex
//
//  Created by Juliana on 11/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//
//

import Foundation
import CoreData


extension Pokemon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pokemon> {
        return NSFetchRequest<Pokemon>(entityName: "Pokemon")
    }

    @NSManaged public var color: String?
    @NSManaged public var height: Int16
    @NSManaged public var id: Int16
    @NSManaged public var indexes: [String: String]?
    @NSManaged public var name: String?
    @NSManaged public var text_entry: String?
    @NSManaged public var types: [String]?
    @NSManaged public var weight: Int16
    @NSManaged public var evolutionChain: [Int16]?
    @NSManaged public var pokemonId: PokemonId?

}
