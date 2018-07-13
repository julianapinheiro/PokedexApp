//
//  PokemonInfoActions.swift
//  Pokédex
//
//  Created by Juliana on 04/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

// Called from PokedexListViewController when Pokemon is selected
struct SelectPokemonIdAction: Action {
    let selectedPokemonId: PokemonId
}

// Called after fetching Pokemon
struct UpdatePokemonAction: Action {
    let selectedPokemon: Pokemon!
}

// Called after fetching Pokemon
struct AppendPokemonInfoList: Action {
    let pokemon: Pokemon
}

struct SetPokemonInfoList: Action {
    let list: [Pokemon]
}
