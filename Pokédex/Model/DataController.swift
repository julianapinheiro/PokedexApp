//
//  DataController.swift
//  Pokédex
//
//  Created by Juliana on 03/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper

class PrivateMapContext: MapContext {
    
    let privateContextMap : NSManagedObjectContext
    
    init(_ context: NSManagedObjectContext) {
        self.privateContextMap = context
    }
}

class DataController {
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /*init(modelName: String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
    }*/
    
    // For testing
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
    
    convenience init(modelName: String) {
        self.init(container: NSPersistentContainer(name: modelName))
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores(completionHandler: {storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.viewContext.automaticallyMergesChangesFromParent = true
            self.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            self.autoSaveViewContext()
            completion?()
        })
    }
}

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        guard interval > 0 else {
            print("Cannot set negative autosave interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: {
            self.autoSaveViewContext(interval: interval)
        })
    }
}
