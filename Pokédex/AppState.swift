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
    
    init() {
        self.pokedexListState = PokedexListState()
        print("Init appstate")
    }
    
    init(pokedexListState: PokedexListState) {
        self.pokedexListState = pokedexListState
    }
}
