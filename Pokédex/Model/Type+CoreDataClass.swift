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
    
    private var pokemonListTemp: Array<String>!

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
    
    func fetchPokemon(_ objectContext: NSManagedObjectContext) {
        let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
        for pokemonName in self.pokemonListTemp {
            fetchRequest.predicate = NSPredicate(format: "name = %@", pokemonName.capitalized)
            let pokemon = try! objectContext.fetch(fetchRequest)
            if pokemon.count > 0 {
                self.addToPokemonList(pokemon[0])
            }
        }
        self.pokemonListTemp = nil
    }
    
    let transformPokemonList = TransformOf<Array<String>, Any>(fromJSON: { (value: Any?) -> Array<String>? in
        let pokemonArray = value as! Array<Dictionary<String, Any>>
        var pokemonList:Array<String> = []
        for pokemonItem in pokemonArray {
            let pokemonName = (pokemonItem["pokemon"] as! Dictionary<String, String>)["name"]
            pokemonList.append(pokemonName!)
        }
        return pokemonList
    },  toJSON: { (value: Array<String>?) -> Any? in return "object to json not supported" })
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        pokemonListTemp <- (map["pokemon"], transformPokemonList)
    }
}
