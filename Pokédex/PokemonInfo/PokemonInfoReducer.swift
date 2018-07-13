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
        
    case let action as UpdatePokemonAction:
        state.selectedPokemon = action.selectedPokemon
    
    case let action as AppendPokemonInfoList:
        state.pokemonInfoList.append(action.pokemon)
    
    case let action as SetPokemonInfoList:
        state.pokemonInfoList = action.list

    default:
        break
    }
    
    return state
}
