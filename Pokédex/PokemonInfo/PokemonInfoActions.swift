//
//  PokemonInfoActions.swift
//  Pokédex
//
//  Created by Juliana on 04/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

struct SelectPokemonIdAction: Action {
    let pokemon: PokemonId?
}

struct UpdatePokemonAction: Action {
    let pokemon: Pokemon?
}

struct AppendPokemonInfoList: Action {
    let pokemon: Pokemon
}

struct SetPokemonInfoList: Action {
    let list: [Pokemon]
}
