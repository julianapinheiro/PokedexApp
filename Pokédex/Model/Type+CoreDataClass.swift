//
//  Type+CoreDataClass.swift
//  Pokédex
//
//  Created by Juliana on 10/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//
//

import Foundation
import CoreData
import ObjectMapper

@objc(Type)
public class Type: NSManagedObject, Mappable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init?(map: Map) {
        var objectContext = context
        if let mapContext = map.context as? PrivateMapContext {
            objectContext = mapContext.privateContextMap
        }
        let entity = NSEntityDescription.entity(forEntityName: "Type", in: objectContext)
        super.init(entity: entity!, insertInto: objectContext)
    }
    
    // err
    let transformPokemonList = TransformOf<NSSet, Any>(fromJSON: { (value: Any?) -> NSSet? in
        let pokemonArray = value as! Array<Dictionary<String, Any>>
        var pokemonList:Array<PokemonId> = []
        for pokemonItem in pokemonArray {
            let pokemonName = (pokemonItem["pokemon"] as! Dictionary<String, String>)["name"]
            let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name = %@", pokemonName!.capitalized)
            let pokemon = try! context.fetch(fetchRequest)
            if pokemon.count > 0 {
                pokemonList.append(pokemon[0])
            }
        }
        return NSSet(array: pokemonList)
    },  toJSON: { (value: NSSet?) -> Any? in return "object to json not supported" })
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        pokemonList <- (map["pokemon"], transformPokemonList)
    }
}
