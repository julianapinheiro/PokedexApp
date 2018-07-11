//
//  PokedexListService.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Alamofire
import ObjectMapper
import CoreData

class PokedexListService {
    let pokedexSize:Int = 802
    let typesSize:Int = 18
    let root:String = "http://pokeapi.co/api/v2/"
    let spritePath:URL = PokedexListService.getDocumentsDirectory().appendingPathComponent("pokemon")
    
    static let shared = PokedexListService()

    // -------------------------------------------------------------------------
    // MARK: - Init Pokemon, PokemonId, Type Objects
    
    func startPokemon() {
        // Try and fetch Pokemon from CoreData
        let listFetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        listFetchRequest.sortDescriptors = [sortDescriptor]
        
        let pokedexInfoList = try! context.fetch(listFetchRequest)
        store.dispatch(SetPokemonInfoList(list: pokedexInfoList))
    }
    
    func startTypes(completion: @escaping (_ success: Bool) -> Void) {
        // Try and fetch Type from CoreData
        let fetchRequest:NSFetchRequest<Type> = Type.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var typesList = try! context.fetch(fetchRequest)
        
        // If not found in CoreData, fetch from API and save in CoreData
        if typesList.isEmpty {
            fetchTypes(1, completion: { success in
                if success {
                    print("PokedexListServices: Types fetched from API")
                    typesList = try! context.fetch(fetchRequest)
                    store.dispatch(UpdateTypesListAction(list: typesList))
                    completion(true)
                }
            })
        } else {
            print("PokedexListServices: Types fetched from CoreData")
            store.dispatch(UpdateTypesListAction(list: typesList))
            completion(true)
        }
    }
    
    func startPokedex(completion: @escaping (_ success: Bool) -> Void) {
        // Try and fetch PokemonId from CoreData
        let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var pokedexList = try! context.fetch(fetchRequest)
        
        // If not found in CoreData, fetch from API and save in CoreData
        if pokedexList.isEmpty {
            fetchPokedex {success in
                if success {
                    print("PokedexListServices: Pokedex fetched from API")
                    pokedexList = try! context.fetch(fetchRequest)
                    store.dispatch(UpdateListAction(list: pokedexList))
                    completion(true)
                }
            }
        } else {
            print("PokedexListServices: Pokedex fetched from CoreData")
            store.dispatch(UpdateListAction(list: pokedexList))
            completion(true)
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Fetch Methods
    
    // -- Fetch from pokemon/limit?=802
    // Um request cria todos os objetos PokemonId :D
    func fetchPokedex(completion: @escaping (_ success: Bool) -> Void) {
        Alamofire.request((URL(string: root + "pokemon/?limit=" + String(pokedexSize)))!).responseJSON(completionHandler: { response in
            if let json = response.result.value as! [String: Any]? {
                let pokemonList = json["results"] as! Array<Dictionary<String, Any>>
                for pokemonItem in pokemonList  {
                    let pokemon = PokemonId(JSON: pokemonItem)
                    context.insert(pokemon!)
                    try! context.save()
                    //print("Saving object PokemonId id=\(pokemon!.id)")
                }
                completion(true)
            }
        })
    }
    
    // -- Fetch Sprite from API
    func fetchSprite(pokemonId: Int, completion: (_ success: Bool) -> Void) {
        
        // If file already exists
        let dirPath = PokedexListService.getDocumentsDirectory().appendingPathComponent("pokemon")
        let filePath = dirPath.appendingPathComponent(String(pokemonId) + ".png")
        if FileManager.default.fileExists(atPath: filePath.relativePath) {
            //print("Pokemon Sprite already saved for id=" + String(pokemonId))
            return
        }
        
        // Create Directory "pokemon"
        try! FileManager.default.createDirectory(atPath: dirPath.relativePath, withIntermediateDirectories: true)
        
        //placeholder
        let spritePath = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + String(pokemonId) + ".png"
        
        // Fetch image from API
        let data = try! Data(contentsOf: URL(string: spritePath)!)
        let image = UIImage(data: data, scale: UIScreen.main.scale)!
        let pngImage = UIImagePNGRepresentation(image)
        
        // Save image locally
        try! pngImage?.write(to: filePath, options: .atomic)
        //print("Saving Sprite for id=" + String(pokemonId))
        completion(true)
    }
    
    var index = 1
    
    func fetchTypes(_ id: Int, completion: @escaping (_ success: Bool) -> Void) {
        let url = URL(string: root)?.appendingPathComponent("type").appendingPathComponent(String(id)).appendingPathComponent("/")
        Alamofire.request(url!).responseJSON(completionHandler: { response in
            if let json = response.result.value as! [String: Any]? {
                let type = Type(JSON: json)
                context.insert(type!)
                try! context.save()
                //print("PokedexListServices: Fetched and saved Type name=\(type!.name!)")
                if self.index < self.typesSize - 1 {
                    self.index += 1
                    self.fetchTypes(self.index + 1, completion: { success in
                        if success {
                            completion(true)
                        }
                    })
                } else {
                    //print("PokedexListServices: fetched all types from API")
                    completion(true)
                }
            }
        })
    }
    
    // HELPER
    
    // Return path for Documents
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    

}
