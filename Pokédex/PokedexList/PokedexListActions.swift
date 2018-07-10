//
//  PokedexListActions.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

struct UpdateListAction: Action {
    let list: [PokemonId]
}

struct UpdateTypesListAction: Action {
    let list: [Type]
}

struct UpdateFilteredPokemon: Action {
    let list: [PokemonId]
}

struct SetIsFiltering: Action {
    let isFiltering: Bool
}
