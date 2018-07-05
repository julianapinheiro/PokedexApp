//
//  AppReducer.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    let state = state ?? AppState()
    return AppState(
        pokedexListState: pokedexListReducer(action: action, state: state.pokedexListState),
        pokemonInfoState: pokemonInfoReducer(action: action, state: state.pokemonInfoState)
    )
}
