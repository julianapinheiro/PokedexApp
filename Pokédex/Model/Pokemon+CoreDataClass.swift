//
//  Pokemon+CoreDataClass.swift
//  Pokédex
//
//  Created by Juliana on 05/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//
//

import Foundation
import CoreData
import ObjectMapper

@objc(Pokemon)
public class Pokemon: NSManagedObject, Mappable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init?(map: Map) {
        var objectContext = context
        if let mapContext = map.context as? PrivateMapContext {
            objectContext = mapContext.privateContextMap
        }
        let entity = NSEntityDescription.entity(forEntityName: "Pokemon", in: objectContext)
        super.init(entity: entity!, insertInto: objectContext)
    }
    
    // crying in pokemon language
    let transformTextEntry = TransformOf<String, Any>(fromJSON: { (value: Any?) -> String? in
        let text_entries = value as! Array<Dictionary<String, Any>>
        var text:String = ""
        for entry in text_entries {
            let entry_lan = entry["language"] as! Dictionary<String, String>
            let entry_ver = entry["version"] as! Dictionary<String, String>
            if entry_lan["name"] == "en" {
                text = entry["flavor_text"] as! String
                break
            }
        }
        return text.replacingOccurrences(of: "\n", with: " ")
    },  toJSON: { (value: String?) -> Any? in return "object to json not supported" })
    
    let transformPokedexNumbers = TransformOf<Dictionary<String, String>, Any>(fromJSON: { (value: Any?) -> Dictionary<String, String>? in
        let pokedex_entries = value as! Array<Dictionary<String, Any>>
        var pokedex_numbers: Dictionary<String, String> = [:]
        for entry in pokedex_entries {
            let entry_number = entry["entry_number"] as! Int
            let entry_dex = entry["pokedex"] as! Dictionary<String, String>
            pokedex_numbers[entry_dex["name"]!] = String(entry_number)
        }
        return pokedex_numbers
    },  toJSON: { (value: Dictionary<String, String>?) -> Any? in return "object to json not supported" })
    
    let transformTypes = TransformOf<Array<String>, Any>(fromJSON: { (value: Any?) -> Array<String>? in
        let types_entries = value as! Array<Dictionary<String, Any>>
        let type_entry0 = types_entries[0] as Dictionary<String, Any>
        if types_entries.count > 1 {
            let type_entry1 = types_entries[1] as Dictionary<String, Any>
            let type0:String
            let type1:String
            if type_entry0["slot"] as! Int == 1 {
                type0 = ((type_entry0["type"] as! Dictionary<String, String>)["name"])!
                type1 = ((type_entry1["type"] as! Dictionary<String, String>)["name"])!
            } else {
                type1 = ((type_entry0["type"] as! Dictionary<String, String>)["name"])!
                type0 = ((type_entry1["type"] as! Dictionary<String, String>)["name"])!
            }
            return [type0, type1]
        } else {
            return [((type_entry0["type"] as! Dictionary<String, String>)["name"])!]
        }
    } ,  toJSON: { (value: Array<String>?) -> Any? in return "object to json not supported" })
    
    
    static func urlToId(_ URLString: String) -> Int16 {
        let url = URL(string: URLString)
        return Int16((url?.pathComponents.last!)!)!
    }
    
    let transformChain = TransformOf<[Int16], Any>(fromJSON: { (value: Any?) -> [Int16]? in
        let chainDict = value as! Dictionary<String, Any>
        var chain: Array<Int16> = []
       
        // First form
        var form = urlToId((chainDict["species"] as! Dictionary<String, String>)["url"]!)
        chain.append(form)
        
        // First Evolutions
        let evolutionsArray = chainDict["evolves_to"] as! Array<Dictionary<String, Any>>
        for evolution in evolutionsArray {
            if evolution.count > 0 {
                // Second form
                form = urlToId((evolution["species"]! as! Dictionary<String, String>)["url"]!)
                chain.append(form)
                
                // Second evolutions
                let secondEvolutionsArray = evolution["evolves_to"] as! Array<Dictionary<String, Any>>
                for secondEvolution in secondEvolutionsArray {
                    if secondEvolution.count > 0 {
                        // Third form
                        form = urlToId((secondEvolution["species"]! as! Dictionary<String, String>)["url"]!)
                        chain.append(form)
                    }
                }
           }
        }
        return chain
    },  toJSON: { (value: [Int16]?) -> Any? in return "object to json not supported" })
    
    let transformPokemonId = TransformOf<PokemonId, Any>(fromJSON: { (value: Any?) -> PokemonId? in
        let id = value as! Int16
        let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %x", id)
        let pokemon = try! context.fetch(fetchRequest)
        if pokemon.count > 0 {
            return pokemon[0]
        } else {
            return nil
        }
    },  toJSON: { (value: PokemonId?) -> Any? in return "object to json not supported" })
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        height <- map["height"]
        weight <- map["weight"]
        color <- map["color.name"]
        types <- (map["types"], transformTypes)
        pokemonId <- (map["id"], transformPokemonId)
        evolutionChain <- (map["chain"], transformChain)
        indexes <- (map["pokedex_numbers"], transformPokedexNumbers)
        text_entry <- (map["flavor_text_entries"], transformTextEntry)
    }
}

