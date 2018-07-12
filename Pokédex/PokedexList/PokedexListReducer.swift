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
    case let action as UpdateListAction:
        state.pokedexList = action.list
    case let action as UpdateTypesListAction:
        state.typesList = action.list
    case let action as UpdateFilteredPokemon:
        state.filteredPokedexList = action.list
    case let action as SetTypeScope:
        state.typeScope = action.scope
        if state.typeScope == nil {
            state.filteredPokedexList = state.pokedexList
            state.isFiltering = false
        } else {
            state.filteredPokedexList = state.pokedexList.filter({( pokemon : PokemonId) -> Bool in
                var doesCategoryMatch = (state.typeScope == nil)
                if state.typeScope != nil {
                    doesCategoryMatch = (state.typeScope!.pokemonList?.contains(pokemon))!
                }
                return doesCategoryMatch
            })
            state.isFiltering = true
        }
    default:
        break
    }
    
    return state
}
