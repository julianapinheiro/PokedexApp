//
//  PokedexListReducer.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

func pokedexListReducer(action: Action, state: PokedexListState?) -> PokedexListState {
    var state = state ?? PokedexListState()
    
    switch action {
    case let action as UpdatePokedexListAction:
        state.pokedexList = action.list
    case let action as UpdateTypesListAction:
        state.typesList = action.list
    case let action as UpdateGenListAction:
        state.genList = action.list
    case let action as UpdateFilteredListAction:
        state.filteredPokedexList = action.list
    case let action as SetTypeScopeAction:
        state.typeScope = action.type
        if state.typeScope == nil && state.genScope == nil {
            state.isFiltering = false
        } else {
            state.isFiltering = true
        }
        state.filteredPokedexList = sortPokedex(state: state)
    case let action as SetGenScopeAction:
        state.genScope = action.gen
        if state.genScope == nil && state.typeScope == nil {
            state.isFiltering = false
        } else {
            state.isFiltering = true
        }
        state.filteredPokedexList = sortPokedex(state: state)
    default:
        break
    }
    
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
