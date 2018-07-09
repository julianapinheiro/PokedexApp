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
    var typesList:[String]

    init() {
        self.pokedexList = []
        self.typesList = []
    }
    
    init? (pokedexList: [PokemonId], typesList: [String]) {
        self.pokedexList = pokedexList
        self.typesList = typesList
    }
}
