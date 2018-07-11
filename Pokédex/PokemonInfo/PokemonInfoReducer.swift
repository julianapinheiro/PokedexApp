//
//  PokemonInfoReducer.swift
//  Pokédex
//
//  Created by Juliana on 04/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

func pokemonInfoReducer(action: Action, state: PokemonInfoState) -> PokemonInfoState {
    var state = state
    
    switch action {
        
    case let action as SelectPokemonIdAction:
        state.selectedPokemonId = action.selectedPokemonId
        if let pokemon = state.pokemonInfoList.first(where: {$0.id == action.selectedPokemonId.id}) {
            print("SelectPokemonIdAction: fetching pokemon from state.list")
            state.selectedPokemon = pokemon
            
        } else {
            print("SelectPokemonIdAction: fetching pokemon from api")
            PokemonInfoServices.shared.fetchPokemon(id: Int(action.selectedPokemonId.id))
        }
        
    case let action as UpdatePokemonAction:
        state.selectedPokemon = action.selectedPokemon
        print("UpdatePokemonAction")
    
    case let action as AppendPokemonInfoList:
        state.pokemonInfoList.append(action.pokemon)
        print("AppendPokemonInfoList")
    
    case let action as SetPokemonInfoList:
        state.pokemonInfoList = action.list
        print("SetPokemonInfoList")
        
    default:
        break
    }
    
    return state
}
