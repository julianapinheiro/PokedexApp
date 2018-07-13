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
    var filteredPokedexList:[PokemonId]
    
    var typesList:[Type]
    var genList:[Generation]
    
    var typeScope:Type?
    var genScope:Generation?
    var isFiltering:Bool

    init() {
        self.pokedexList = []
        self.filteredPokedexList = []
        
        self.typesList = []
        self.genList = []
        
        self.typeScope = nil
        self.genScope = nil
        self.isFiltering = false
    }
}
