//
//  PokedexListReducer.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

struct PokedexListReducer {
    typealias Reducer<ReducerStateType> = (_ action: Action, _ state: PokedexListReducer?) -> PokedexListReducer
    
    func handleAction(action: Action, state: PokedexListState?) -> PokedexListState {
        if state == nil {
            return PokedexListState()
        }
        
        switch action {
        case let action as UpdatePokedexListAction:
            return updatePokedexList(state!, action)
        case let action as UpdateTypesListAction:
            return updateTypesList(state!, action)
        case let action as UpdateGenListAction:
            return updateGenList(state!, action)
        case let action as UpdateFilteredListAction:
            return updateFilteredList(state!, action)
        case let action as SetTypeScopeAction:
            return setTypeScope(state!, action)
        case let action as SetGenScopeAction:
            return setGenScope(state!, action)
        default:
            return state!
        }
    }
    
    fileprivate func updatePokedexList(_ state: PokedexListState, _ action: UpdatePokedexListAction) -> PokedexListState {
        var state = state
        state.pokedexList = action.list
        return state
    }
    
    fileprivate func updateTypesList(_ state: PokedexListState, _ action: UpdateTypesListAction) -> PokedexListState {
        var state = state
        state.typesList = action.list
        return state
    }
    
    fileprivate func updateGenList(_ state: PokedexListState, _ action: UpdateGenListAction) -> PokedexListState {
        var state = state
        state.genList = action.list
        return state
    }
    
    fileprivate func updateFilteredList(_ state: PokedexListState, _ action: UpdateFilteredListAction) -> PokedexListState {
        var state = state
        state.filteredPokedexList = action.list
        return state
    }
    
    fileprivate func setTypeScope(_ state: PokedexListState, _ action: SetTypeScopeAction) -> PokedexListState {
        var state = state
        state.typeScope = action.type
        if state.typeScope == nil && state.genScope == nil {
            state.isFiltering = false
        } else {
            state.isFiltering = true
        }
        state.filteredPokedexList = sortPokedex(state: state)
        return state
    }
    
    fileprivate func setGenScope(_ state: PokedexListState, _ action: SetGenScopeAction) -> PokedexListState {
        var state = state
        state.genScope = action.gen
        if state.genScope == nil && state.typeScope == nil {
            state.isFiltering = false
        } else {
            state.isFiltering = true
        }
        state.filteredPokedexList = sortPokedex(state: state)
        return state
    }
    
    fileprivate func sortPokedex(state: PokedexListState) -> [PokemonId] {
        if state.typeScope != nil && state.genScope != nil {
            return state.pokedexList.filter({( pokemon : PokemonId) -> Bool in
                return (state.genScope!.pokemonList?.contains(pokemon))! && (state.typeScope!.pokemonList?.contains(pokemon))!
            })
        } else if state.typeScope != nil {
            return state.pokedexList.filter({( pokemon : PokemonId) -> Bool in
                return (state.typeScope!.pokemonList?.contains(pokemon))!
            })
        } else if state.genScope != nil {
            return state.pokedexList.filter({( pokemon : PokemonId) -> Bool in
                return (state.genScope!.pokemonList?.contains(pokemon))!
            })
        } else {
            return state.pokedexList
        }
    }
}
