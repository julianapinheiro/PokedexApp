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
            print("fetch info from coredata")
            state.selectedPokemon = pokemon
        } else {
            fetchPokemon(id: Int(action.selectedPokemonId.id))
        }
    case let action as UpdatePokemonAction:
        state.selectedPokemon = action.selectedPokemon
    default:
        break
    }
    
    return state
}
