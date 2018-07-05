//
//  AppState.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import ReSwift

struct AppState: StateType {
    var pokedexListState:PokedexListState
    var pokemonInfoState:PokemonInfoState
    
    init() {
        self.pokedexListState = PokedexListState()
        self.pokemonInfoState = PokemonInfoState()
    }
    
    init(pokedexListState: PokedexListState, pokemonInfoState: PokemonInfoState) {
        self.pokedexListState = pokedexListState
        self.pokemonInfoState = pokemonInfoState
    }
}
