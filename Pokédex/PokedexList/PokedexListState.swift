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
    var typesList:[Type]
    var filteredPokedexList:[PokemonId]

    init() {
        self.pokedexList = []
        self.typesList = []
        self.filteredPokedexList = []
    }
}
