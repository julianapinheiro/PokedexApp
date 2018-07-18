//
//  PokemonInfoReducer.swift
//  Pokédex
//
//  Created by Juliana on 04/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

struct PokemonInfoReducer {
    typealias ReducerStateType = PokemonInfoState
    
    func handleAction(action: Action, state: PokemonInfoState?) -> PokemonInfoState {
        if state == nil {
            return PokemonInfoState()
        }
        
        switch action {
        case let action as SelectPokemonIdAction:
            return selectPokemonId(state!, action)
        case let action as UpdatePokemonAction:
            return updatePokemon(state!, action)
        case let action as AppendPokemonInfoList:
            return appendPokemonInfoList(state!, action)
        case let action as SetPokemonInfoList:
            return setPokemonInfoList(state!, action)
        default:
            return state!
        }
    }
    
    fileprivate func selectPokemonId(_ state: PokemonInfoState, _ action: SelectPokemonIdAction) -> PokemonInfoState {
        var state = state
        state.selectedPokemonId = action.pokemon
        return state
    }
    
    fileprivate func updatePokemon(_ state: PokemonInfoState, _ action: UpdatePokemonAction) -> PokemonInfoState {
        var state = state
        state.selectedPokemon = action.pokemon
        return state
    }
    
    fileprivate func appendPokemonInfoList(_ state: PokemonInfoState, _ action: AppendPokemonInfoList) -> PokemonInfoState {
        var state = state
        state.pokemonInfoList.append(action.pokemon)
        return state
    }
    
    fileprivate func setPokemonInfoList(_ state: PokemonInfoState, _ action: SetPokemonInfoList) -> PokemonInfoState {
        var state = state
        state.pokemonInfoList = action.list
        return state
    }
    
}
