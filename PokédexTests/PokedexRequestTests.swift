//
//  Poke_dexTests.swift
//  PokédexTests
//
//  Created by Juliana on 12/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import XCTest
@testable import Poke_dex
@testable import Alamofire
@testable import AlamofireImage

class PokedexRequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRequestAllToApi() {
        let url = URL(string: PokedexListService.shared.root + "pokemon/?limit=" + String(PokedexListService.shared.pokedexSize))
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        Alamofire.request(url!).responseJSON(completionHandler: { response in
            statusCode = response.response?.statusCode
            responseError = response.error
            promise.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
    
    func testRequestSprites() {
        let cases = [1, 2, 100, 801, 802]
        for index in cases {
            let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + String(index) + ".png")
            let promise = expectation(description: "Completion handler invoked")
            var statusCode: Int?
            var responseError: Error?
            
            Alamofire.request(url!).responseImage (completionHandler: { response in
                statusCode = response.response?.statusCode
                responseError = response.error
                promise.fulfill()
            })
            
            waitForExpectations(timeout: 5, handler: nil)
            
            XCTAssertNil(responseError)
            XCTAssertEqual(statusCode, 200)
        }
    }
}
