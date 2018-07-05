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

func fetchPokemon(id: Int) {
    print("Fetching pokemon from API id=" + String(id))
    // Fetch pokemon/id
    Alamofire.request((URL(string: root + "pokemon/" + String(id)))!).responseJSON(completionHandler: { response in
        print("Did request")
        if let pokemonJSON = response.result.value as! [String : Any]? {
            // Fetch pokemon-species/id
            Alamofire.request((URL(string: root + "pokemon-species/" + String(id)))!).responseJSON(completionHandler: { response in
                print("Did request species")
                if let pokemonSpeciesJSON = response.result.value as! [String : Any]? {
                    let json = pokemonJSON.merging(pokemonSpeciesJSON, uniquingKeysWith: {(current, _) in current })
                    let pokemon = Pokemon(JSON: json)
                    context.insert(pokemon!)
                    store.dispatch(UpdatePokemonAction(selectedPokemon: pokemon!))
                }
            })
            
        }
        
    })
    
}

/*
 if let json = response.result.value {
 let poke = Pokemon(JSON: json as! [String : Any])
 context.insert(poke!)
 try! context.save()
 fetchSprite(pokemonId: id, completion: {_ in
 completion(true)
 })
 }
 */
