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

class PokemonInfoServices {
    static let shared = PokemonInfoServices()
    
    // Fetch info from pokemon/id and pokemon-species/id endpoints
    // Merges both json and creates Pokemon object
    func fetchPokemon(id: Int) {
        //print("PokemonInfoServices: Fetching pokemon from API id=" + String(id))
        
        // Fetch pokemon/id
        Alamofire.request((URL(string: PokedexListService.shared.root + "pokemon/" + String(id)))!).responseJSON(completionHandler: { response in
            //print("PokemonInfoServices: Did request")
            if let pokemonJSON = response.result.value as! [String : Any]? {
                
                // Fetch pokemon-species/id
                Alamofire.request((URL(string: PokedexListService.shared.root + "pokemon-species/" + String(id)))!).responseJSON(completionHandler: { response in
                    //print("PokemonInfoServices: Did request species")
                    if let pokemonSpeciesJSON = response.result.value as! [String : Any]? {
                        let chainUrl:String = (pokemonSpeciesJSON["evolution_chain"] as! Dictionary<String, String>)["url"]!
                        
                        // Fetch evolution-chain/evoid
                        Alamofire.request(URL(string: chainUrl)!).responseJSON(completionHandler: { response in
                            //print("PokemonInfoServices: Did request chain")
                            if let pokemonChainJSON = response.result.value as! [String : Any]? {
                                
                                let json = pokemonJSON.merging(pokemonSpeciesJSON, uniquingKeysWith: {(current, _) in current }).merging(pokemonChainJSON, uniquingKeysWith: {(current, _) in current })
                                let pokemon = Pokemon(JSON: json)
                                pokemon!.id = Int16(id)
                                context.insert(pokemon!)
                                try! context.save()
                                print("PokemonInfoServices: Fetched and saved Pokemon id=\(pokemon!.id)")
                                store.dispatch(UpdatePokemonAction(selectedPokemon: pokemon!)) // Update Selected
                                store.dispatch(AppendPokemonInfoList(pokemon: pokemon!))       // Add to list
                                
                            }
                        })
                    }
                })
                
            }
            
        })
        
    }
}

