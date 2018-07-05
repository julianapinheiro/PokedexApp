//
//  PokedexListState.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

struct PokedexListState {
    var pokedexList:[PokemonId]

    init() {
        self.pokedexList = []
    }
    
    init? (pokedexList: [PokemonId]) {
        self.pokedexList = pokedexList
    }
}
