//
//  PokemonId+CoreDataClass.swift
//  Pokédex
//
//  Created by Juliana on 11/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//
//

import Foundation
import CoreData
import ObjectMapper

@objc(PokemonId)
public class PokemonId: NSManagedObject, Mappable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init?(map: Map) {
        var objectContext = context
        if let mapContext = map.context as? PrivateMapContext {
            objectContext = mapContext.privateContextMap
        }
        let entity = NSEntityDescription.entity(forEntityName: "PokemonId", in: objectContext)
        super.init(entity: entity!, insertInto: objectContext)
    }
    
    let transformId = TransformOf<Int16, Any>(fromJSON: { (value: Any?) -> Int16 in
        let url = URL(string: value as! String)
        let id = Int16((url?.pathComponents.last!)!)!
        return id
    },  toJSON: { (value: Int16?) -> Any? in return "object to json not supported" } )
    
    let transformName = TransformOf<String, Any>(fromJSON: { (value: Any?) -> String? in
        let name = value as! String
        return name.capitalized.replacingOccurrences(of: "-", with: " ")
    },  toJSON: { (value: String?) -> Any? in return "object to json not supported" } )
    
    public func mapping(map: Map) {
        id <- (map["url"], transformId)
        name <- (map["name"], transformName)
    }
}
