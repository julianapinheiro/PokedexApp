//
//  PokemonInfoState.swift
//  Pokédex
//
//  Created by Juliana on 04/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

struct PokemonInfoState {
    var selectedPokemonId:PokemonId
    var selectedPokemon:Pokemon?
    
    var pokemonInfoList: [Pokemon]
    
    init () {
        self.selectedPokemonId = PokemonId()
        self.selectedPokemon = nil
        self.pokemonInfoList = []
    }
    
    /*init ? (selectedPokemonId: PokemonId) {
        self.selectedPokemonId = selectedPokemonId
        self.selectedPokemon = nil
        self.pokemonInfoList = []
    }*/
}
