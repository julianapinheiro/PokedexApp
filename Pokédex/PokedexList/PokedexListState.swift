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
    var genList:[Generation]
    var filteredPokedexList:[PokemonId]
    var typeScope:Type?
    var isFiltering:Bool

    init() {
        self.pokedexList = []
        self.typesList = []
        self.genList = []
        self.filteredPokedexList = []
        self.typeScope = nil
        self.isFiltering = false
    }
}
