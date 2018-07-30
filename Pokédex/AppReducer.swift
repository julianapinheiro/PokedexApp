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
    
    let pokedexListReducer = PokedexListReducer()
    let pokemonInfoReducer = PokemonInfoReducer()
    
    return AppState(
        pokedexListState: pokedexListReducer.handleAction(action: action, state: state.pokedexListState),
        pokemonInfoState: pokemonInfoReducer.handleAction(action: action, state: state.pokemonInfoState)
    )
}
