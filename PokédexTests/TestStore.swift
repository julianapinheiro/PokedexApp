//
//  TestStore.swift
//  PokédexTests
//
//  Created by Juliana on 13/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

class TestStore: DispatchingStoreType {
    var dispatchedActions: [Action] = []
    func dispatch(_ action: Action) {
        dispatchedActions.append(action)
    }
}
