//
//  AppReducer.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(pokedexListState: PokedexListState())
}
