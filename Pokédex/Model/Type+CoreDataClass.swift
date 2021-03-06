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
    
    private var pokemonListTemp: Array<Int16>!

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
        for pokemonIndex in self.pokemonListTemp {
            fetchRequest.predicate = NSPredicate(format: "id = %x", pokemonIndex)
            let pokemon = try! objectContext.fetch(fetchRequest)
            if pokemon.count > 0 {
                self.addToPokemonList(pokemon[0])
            }
        }
        self.pokemonListTemp = nil
    }
    
    let transformPokemonList = TransformOf<Array<Int16>, Any>(fromJSON: { (value: Any?) -> Array<Int16>? in
        let pokemonArray = value as! Array<Dictionary<String, Any>>
        var pokemonList:Array<Int16> = []
        for pokemonItem in pokemonArray {
            let pokemonUrl = URL(string: (pokemonItem["pokemon"] as! Dictionary<String, String>)["url"]!)
            let pokemonIndex = Int16((pokemonUrl?.pathComponents.last!)!)
            pokemonList.append(pokemonIndex!)
        }
        return pokemonList
    },  toJSON: { (value: Array<Int16>?) -> Any? in return "object to json not supported" })
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        pokemonListTemp <- (map["pokemon"], transformPokemonList)
    }
}
