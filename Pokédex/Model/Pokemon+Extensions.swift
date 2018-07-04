//
//  Pokemon+Extensions.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import ObjectMapper
import CoreData

extension Pokemon: StaticMappable {
    public static func objectForMapping(map: Map) -> BaseMappable? {
        return Pokemon() //context: NSManagedObjectContext()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        height <- map["height"]
        weight <- map["weight"]
        //indexes <- (map["pokedex_numbers"])
    }
}
