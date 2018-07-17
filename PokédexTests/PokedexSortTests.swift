//
//  PokedexSortTests.swift
//  PokédexTests
//
//  Created by Juliana on 17/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import XCTest
@testable import Poke_dex
@testable import ReSwift

class PokedexSortTests: XCTestCase {
    
    var testStore: Store<AppState>!
    var pokedexService: PokedexListService!
    
    override func setUp() {
        super.setUp()
        testStore = Store(reducer: appReducer, state: AppState())
        pokedexService = PokedexListService(serviceStore: testStore)
        let promise = expectation(description: "Completion handler invoked")
        pokedexService.loadData(completion: { success in
            if success {
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        testStore = nil
        pokedexService = nil
    }
    
    func testSortByType() {
        let types = testStore.state.pokedexListState.typesList
        let pokedexSize = testStore.state.pokedexListState.pokedexList.count
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, pokedexSize)
        
        testStore.dispatch(SetTypeScopeAction(type: types.first(where:{ $0.name == "normal" }) ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 109) // Normal
        
        testStore.dispatch(SetTypeScopeAction(type: types.first(where:{ $0.name == "fairy" }) ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 47) // Fairy
        
        testStore.dispatch(SetTypeScopeAction(type: nil ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, pokedexSize) // All
    }
    
    func testSortByGen() {
        let generations = testStore.state.pokedexListState.genList
        let pokedexSize = testStore.state.pokedexListState.pokedexList.count
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, pokedexSize)
        
        testStore.dispatch(SetGenScopeAction(gen: generations.first(where:{ $0.name == "generation-i" }) ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 151) // Gen I
        
        testStore.dispatch(SetGenScopeAction(gen: generations.first(where:{ $0.name == "generation-v" }) ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 156) // Gen V
        
        testStore.dispatch(SetGenScopeAction(gen: nil ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, pokedexSize)
    }
    
    func testSort() {
        let types = testStore.state.pokedexListState.typesList
        let generations = testStore.state.pokedexListState.genList
        let pokedexSize = testStore.state.pokedexListState.pokedexList.count
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, pokedexSize)
        
        testStore.dispatch(SetGenScopeAction(gen: generations.first(where:{ $0.name == "generation-i" }) ))
        testStore.dispatch(SetTypeScopeAction(type: types.first(where:{ $0.name == "normal" }) ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 22) // Gen I Normal
        
        testStore.dispatch(SetTypeScopeAction(type: types.first(where:{ $0.name == "water" }) ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 32) // Gen I Water
        
        testStore.dispatch(SetGenScopeAction(gen: nil ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 131) // All Water
        
        testStore.dispatch(SetTypeScopeAction(type: nil ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, pokedexSize) // All
        
        testStore.dispatch(SetTypeScopeAction(type: types.first(where:{ $0.name == "water" }) ))
        testStore.dispatch(SetGenScopeAction(gen: generations.first(where:{ $0.name == "generation-iii" }) ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 28) // Gen III Water
        
        testStore.dispatch(SetGenScopeAction(gen: generations.first(where:{ $0.name == "generation-v" }) ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, 17) // Gen V Water
        
        testStore.dispatch(SetGenScopeAction(gen: nil ))
        testStore.dispatch(SetTypeScopeAction(type: nil ))
        XCTAssertEqual(testStore.state.pokedexListState.filteredPokedexList.count, pokedexSize) // All
    }
    
}
