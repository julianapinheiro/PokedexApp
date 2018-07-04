//
//  Pokemon+CoreDataClass.swift
//  Pokédex
//
//  Created by Juliana on 03/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//
//

import Foundation
import CoreData
import ObjectMapper

@objc(Pokemon)
public class Pokemon: NSManagedObject, Mappable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init?(map: Map) {
        // ???????? por que
        let objectContext = context
        let entity = NSEntityDescription.entity(forEntityName: "Pokemon", in: objectContext)
        super.init(entity: entity!, insertInto: objectContext)

    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        height <- map["height"]
        weight <- map["weight"]
        //indexes <- (map["pokedex_numbers"])
    }
}
