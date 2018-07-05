//
//  PokedexListReducer.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

func pokedexListReducer(action: Action, state: PokedexListState?) -> PokedexListState {
    var state = state ?? PokedexListState()

    switch action {
    case let action as UpdateListAction:
        state.pokedexList = action.list
    default:
        break
    }
    
    return state
}
