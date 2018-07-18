//
//  PokedexListStateTests.swift
//  PokédexTests
//
//  Created by Juliana on 17/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import XCTest
@testable import Poke_dex
@testable import ReSwift

class PokedexListStateTests: XCTestCase {
    
    var testStore: Store<AppState>!
    
    override func setUp() {
        super.setUp()
        testStore = Store(reducer: appReducer, state: AppState())
    }
    
    override func tearDown() {
        super.tearDown()
        testStore = nil
    }
    
    
    func testUpdatePokedexList() {
        var action = UpdatePokedexListAction(list: [PokemonId(), PokemonId(), PokemonId()])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokedexListState.pokedexList.count, 3)
        
        action = UpdatePokedexListAction(list: [])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokedexListState.pokedexList.count, 0)
    }
    
    func testUpdateTypesList() {
        var action = UpdateTypesListAction(list: [Type(), Type(), Type()])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokedexListState.typesList.count, 3)
        
        action = UpdateTypesListAction(list: [])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokedexListState.typesList.count, 0)
    }
    
    func testUpdateGenList() {
        var action = UpdateGenListAction(list: [Generation(), Generation(), Generation()])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokedexListState.genList.count, 3)
        
        action = UpdateGenListAction(list: [])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokedexListState.genList.count, 0)
    }
    
    func testUpdateFilteredList() {
        var action = UpdateFilteredListAction(list: [PokemonId(), PokemonId(), PokemonId()])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 3)
        
        action = UpdateFilteredListAction(list: [])
        testStore.dispatch(action)
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 0)
    }
    
    func testSetTypeScope() {
        var action = SetTypeScopeAction(type: Type())
        testStore.dispatch(action)
        XCTAssertTrue(testStore.state.pokedexListState.isFiltering)
        XCTAssertNotNil(testStore.state.pokedexListState.typeScope)
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 0)
        
        action = SetTypeScopeAction(type: nil)
        testStore.dispatch(action)
        XCTAssertFalse(testStore.state.pokedexListState.isFiltering)
        XCTAssertNil(testStore.state.pokedexListState.typeScope)
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, testStore.state.pokedexListState.pokedexList.count)
    }
    
    func testSetGenScope() {
        var action = SetGenScopeAction(gen: Generation())
        testStore.dispatch(action)
        XCTAssertTrue(testStore.state.pokedexListState.isFiltering)
        XCTAssertNotNil(testStore.state.pokedexListState.genScope)
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 0)
        
        action = SetGenScopeAction(gen: nil)
        testStore.dispatch(action)
        XCTAssertFalse(testStore.state.pokedexListState.isFiltering)
        XCTAssertNil(testStore.state.pokedexListState.genScope)
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, testStore.state.pokedexListState.pokedexList.count)
    }
    
    func testSetScope() {
        var typeAction = SetTypeScopeAction(type: Type())
        var genAction = SetGenScopeAction(gen: Generation())
        testStore.dispatch(typeAction)
        testStore.dispatch(genAction)
        
        XCTAssertTrue(testStore.state.pokedexListState.isFiltering)
        XCTAssertNotNil(testStore.state.pokedexListState.genScope)
        XCTAssertNotNil(testStore.state.pokedexListState.typeScope)
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 0)
        
        typeAction = SetTypeScopeAction(type: nil)
        testStore.dispatch(typeAction)
        XCTAssertTrue(testStore.state.pokedexListState.isFiltering)
        XCTAssertNil(testStore.state.pokedexListState.typeScope)
        
        genAction = SetGenScopeAction(gen: nil)
        testStore.dispatch(genAction)
        XCTAssertFalse(testStore.state.pokedexListState.isFiltering)
        XCTAssertNil(testStore.state.pokedexListState.genScope)
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, testStore.state.pokedexListState.pokedexList.count)
    }
}
