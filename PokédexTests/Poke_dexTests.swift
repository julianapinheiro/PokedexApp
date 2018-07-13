//
//  Poke_dexTests.swift
//  PokédexTests
//
//  Created by Juliana on 12/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import XCTest
@testable import Poke_dex

class Poke_dexTests: XCTestCase {
    
    var controllerUnderTest: ViewController!
    var stubDataController: DataController!
    
    override func setUp() {
        super.setUp()
        controllerUnderTest = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ViewController!
        stubDataController = DataController(modelName: "Stub")
        stubDataController.load()
        (UIApplication.shared.delegate as! AppDelegate).dataController = stubDataController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        controllerUnderTest = nil
    }
    
    func testExample() {
        controllerUnderTest.loadData()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
