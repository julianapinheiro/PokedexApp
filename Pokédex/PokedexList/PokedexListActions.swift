//
//  PokedexListActions.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

struct UpdatePokedexListAction: Action {
    let list: [PokemonId]
}

struct UpdateTypesListAction: Action {
    let list: [Type]
}

struct UpdateGenListAction: Action {
    let list: [Generation]
}

struct UpdateFilteredListAction: Action {
    let list: [PokemonId]
}

struct SetTypeScopeAction: Action {
    let type: Type?
}

struct SetGenScopeAction: Action {
    let gen: Generation?
}


