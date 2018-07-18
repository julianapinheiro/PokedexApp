//
//  PokemonInfoStateTests.swift
//  PokédexTests
//
//  Created by Juliana on 18/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import XCTest
@testable import Poke_dex
@testable import ReSwift

class PokemonInfoStateTests: XCTestCase {
    
    var testStore: Store<AppState>!
    
    override func setUp() {
        super.setUp()
        testStore = Store(reducer: appReducer, state: AppState())
    }
    
    override func tearDown() {
        super.tearDown()
        testStore = nil
    }
    
    func testSelectPokemonId() {
        var action = SelectPokemonIdAction(pokemon: PokemonId())
        testStore.dispatch(action)
        XCTAssertNotNil(testStore.state.pokemonInfoState.selectedPokemonId)
        
        action = SelectPokemonIdAction(pokemon: nil)
        testStore.dispatch(action)
        XCTAssertNil(testStore.state.pokemonInfoState.selectedPokemonId)
    }
    
    func testUpdatePokemon() {
        var action = UpdatePokemonAction(pokemon: Pokemon())
        testStore.dispatch(action)
        XCTAssertNotNil(testStore.state.pokemonInfoState.selectedPokemon)
        
        action = UpdatePokemonAction(pokemon: nil)
        testStore.dispatch(action)
        XCTAssertNil(testStore.state.pokemonInfoState.selectedPokemon)
    }
    
    func testSetPokemonInfoList() {
        var action = SetPokemonInfoList(list: [Pokemon()])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokemonInfoState.pokemonInfoList.count, 1)
        
        action = SetPokemonInfoList(list: [])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokemonInfoState.pokemonInfoList.count, 0)
    }
    
    func testAppendPokemonInfoList() {
        let action = AppendPokemonInfoList(pokemon: Pokemon())
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokemonInfoState.pokemonInfoList.count, 1)
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokemonInfoState.pokemonInfoList.count, 2)
    }
    
}
