//
//  PokemonInfoServices.swift
//  Pokédex
//
//  Created by Juliana on 04/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import CoreData

class PokemonInfoServices {
    func loadPokemon(_ id: Int) {
        // Try and fetch Pokemon from CoreData
        let fetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %x", id)
        var pokemon = try! context.fetch(fetchRequest)

        // If not found in CoreData, fetch from API and save in CoreData
        if pokemon.count < 1 {
            fetchPokemon(id, completion: { success in
                if success {
                    print("PokemonInfoServices: Pokemon fetched from API")
                    pokemon = try! context.fetch(fetchRequest)
                    store.dispatch(UpdatePokemonAction(selectedPokemon: pokemon[0]))
                    store.dispatch(AppendPokemonInfoList(pokemon: pokemon[0]))
                    store.dispatch(SetFailedToFetch(failedToFetch: false))
                } else {
                    print("PokemonInfoServices: Error fetching Pokemon from API")
                    store.dispatch(SetFailedToFetch(failedToFetch: true))
                }
            })
        } else {
            print("PokemonInfoServices: Pokemon fetched from CoreData")
            store.dispatch(UpdatePokemonAction(selectedPokemon: pokemon[0]))
            store.dispatch(AppendPokemonInfoList(pokemon: pokemon[0]))
            store.dispatch(SetFailedToFetch(failedToFetch: false))
        }
    }
    
    static let shared = PokemonInfoServices()
    
    // Fetch info from pokemon/id and pokemon-species/id endpoints
    // Merges both json and creates Pokemon object
    func fetchPokemon(_ id: Int, completion: @escaping (_ success: Bool) -> Void) {
        print("PokemonInfoServices: Fetching pokemon from API id=" + String(id))
        // Fetch pokemon/id
        Alamofire.request((URL(string: PokedexListServices.shared.root + "pokemon/" + String(id)))!).responseJSON(completionHandler: { response in
            if (response.result.error != nil) {
                print(response.result.error!)
                completion(false)
                return
            }
            print("PokemonInfoServices: Did request")
            if let pokemonJSON = response.result.value as! [String : Any]? {
                
                // Fetch pokemon-species/id
                Alamofire.request((URL(string: PokedexListServices.shared.root + "pokemon-species/" + String(id)))!).responseJSON(completionHandler: { response in
                    if (response.result.error != nil) {
                        print(response.result.error!)
                        completion(false)
                        return
                    }
                    print("PokemonInfoServices: Did request species")
                    if let pokemonSpeciesJSON = response.result.value as! [String : Any]? {
                        let chainUrl:String = (pokemonSpeciesJSON["evolution_chain"] as! Dictionary<String, String>)["url"]!
                        
                        // Fetch evolution-chain/evoid
                        Alamofire.request(URL(string: chainUrl)!).responseJSON(completionHandler: { response in
                            if (response.result.error != nil) {
                                print(response.result.error!)
                                completion(false)
                                return
                            }
                            //print("PokemonInfoServices: Did request chain")
                            if let pokemonChainJSON = response.result.value as! [String : Any]? {
                                
                                let json = pokemonJSON.merging(pokemonSpeciesJSON, uniquingKeysWith: {(current, _) in current }).merging(pokemonChainJSON, uniquingKeysWith: {(current, _) in current })
                                let pokemon = Pokemon(JSON: json)
                                pokemon!.id = Int16(id)
                                context.insert(pokemon!)
                                try! context.save()
                                print("PokemonInfoServices: Fetched Pokemon id=\(pokemon!.id)")
                                completion(true)
                                
                            }
                        })
                    }
                })
                
            }
            
        })
        
    }
}

