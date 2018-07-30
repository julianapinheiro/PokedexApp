//
//  PokemonInfoService.swift
//  Pokédex
//
//  Created by Juliana on 04/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import CoreData

class PokemonInfoService {
    
    // MARK: Properties
    let root:String = "http://pokeapi.co/api/v2/"
    static let shared = PokemonInfoService()
    
    // -------------------------------------------------------------------------
    // MARK: - Init object method
    
    func loadPokemon(_ id: Int, _ completion: @escaping (_ success: Bool) -> Void) {
        // Try and fetch Pokemon from CoreData
        let fetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %x", id)
        var pokemon = try! context.fetch(fetchRequest)

        // If not found in CoreData, fetch from API and save in CoreData
        if pokemon.count < 1 {
            fetchPokemon(id, completion: { success in
                if success {
                    print("PokemonInfoService: Pokemon fetched from API")
                    pokemon = try! context.fetch(fetchRequest)
                    store.dispatch(UpdatePokemonAction(pokemon: pokemon[0]))
                    store.dispatch(AppendPokemonInfoList(pokemon: pokemon[0]))
                    completion(true)
                } else {
                    print("PokemonInfoService: Error fetching Pokemon from API")
                    completion(false)
                }
            })
        } else {
            print("PokemonInfoService: Pokemon fetched from CoreData")
            store.dispatch(UpdatePokemonAction(pokemon: pokemon[0]))
            store.dispatch(AppendPokemonInfoList(pokemon: pokemon[0]))
            completion(true)
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Create object from JSON method
    
    func createPokemonFromJSON(id: Int, _ JSON: [String: Any], _ objectContext: NSManagedObjectContext) {
        let pokemon = Mapper<Pokemon>(context: PrivateMapContext(objectContext)).map(JSON: JSON)
        pokemon!.id = Int16(id)
        let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %x", id)
        let pokemonId = try! objectContext.fetch(fetchRequest)
        pokemon!.pokemonId = pokemonId[0]
        try! objectContext.save()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Fetch Method
    
    // Fetch info from pokemon/id and pokemon-species/id endpoints
    // Merges both json and creates Pokemon object
    func fetchPokemon(_ id: Int, completion: @escaping (_ success: Bool) -> Void) {
        //print("PokemonInfoService: Fetching pokemon from API id=" + String(id))
        // Fetch pokemon/id
        Alamofire.request((URL(string: root + "pokemon/" + String(id)))!).responseJSON(completionHandler: { response in
            if (response.result.error != nil) {
                print(response.result.error!)
                completion(false)
                return
            }
            //print("PokemonInfoService: Did request")
            if let pokemonJSON = response.result.value as! [String : Any]? {
                
                // Fetch pokemon-species/id
                Alamofire.request((URL(string: self.root + "pokemon-species/" + String(id)))!).responseJSON(completionHandler: { response in
                    if (response.result.error != nil) {
                        print(response.result.error!)
                        completion(false)
                        return
                    }
                    //print("PokemonInfoService: Did request species")
                    if let pokemonSpeciesJSON = response.result.value as! [String : Any]? {
                        let chainUrl:String = (pokemonSpeciesJSON["evolution_chain"] as! Dictionary<String, String>)["url"]!
                        
                        // Fetch evolution-chain/evoid
                        Alamofire.request(URL(string: chainUrl)!).responseJSON(completionHandler: { response in
                            if (response.result.error != nil) {
                                print(response.result.error!)
                                completion(false)
                                return
                            }
                            //print("PokemonInfoService: Did request chain")
                            if let pokemonChainJSON = response.result.value as! [String : Any]? {
                                
                                let json = pokemonJSON.merging(pokemonSpeciesJSON, uniquingKeysWith: {(current, _) in current }).merging(pokemonChainJSON, uniquingKeysWith: {(current, _) in current })
                                self.createPokemonFromJSON(id: id, json, context)
                                //print("PokemonInfoService: Fetched Pokemon id=\(pokemon!.id)")
                                completion(true)
                            }
                        })
                    }
                })
                
            }
            
        })
        
    }
}
