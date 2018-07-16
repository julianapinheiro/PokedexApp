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
    let gensSize: Int = 7
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
        print("PokedexListService: fetched \(pokedexInfoList.count) Pokemon from CoreData")
        store.dispatch(SetPokemonInfoList(list: pokedexInfoList))
    }
    
    func startTypes(completion: @escaping (_ success: Bool) -> Void) {
        // Try and fetch Type from CoreData
        let fetchRequest:NSFetchRequest<Type> = Type.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var typesList = try! context.fetch(fetchRequest)

        // If not found in CoreData, fetch from API and save in CoreData
        if typesList.count < typesSize {
            fetchTypes(1, completion: { success in
                if success {
                    print("PokedexListService: Types fetched from API")
                    typesList = try! context.fetch(fetchRequest)
                    store.dispatch(UpdateTypesListAction(list: typesList))
                    completion(true)
                } else {
                    print("PokedexListService: Error fetching types from API")
                    completion(true)
                }
            })
        } else {
            print("PokedexListService: Types fetched from CoreData")
            store.dispatch(UpdateTypesListAction(list: typesList))
            completion(true)
        }
    }
    
    func startGenerations(completion: @escaping (_ success: Bool) -> Void) {
        // Try and fetch Generations from CoreData
        let fetchRequest:NSFetchRequest<Generation> = Generation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var genList = try! context.fetch(fetchRequest)
        
        // If not found in CoreData, fetch from API and save in CoreData
        if genList.count < gensSize {
            fetchGenerations(1, completion: { success in
                if success {
                    print("PokedexListService: Generations fetched from API")
                    genList = try! context.fetch(fetchRequest)
                    store.dispatch(UpdateGenListAction(list: genList))
                    completion(true)
                } else {
                    print("PokedexListService: Error fetching generations from API")
                    completion(true)
                }
            })
        } else {
            print("PokedexListService: Generations fetched from CoreData")
            store.dispatch(UpdateGenListAction(list: genList))
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
        if pokedexList.count < pokedexSize {
            fetchPokedex (objectContext: context, {success in
                if success {
                    print("PokedexListService: Pokedex fetched from API")
                    pokedexList = try! context.fetch(fetchRequest)
                    store.dispatch(UpdatePokedexListAction(list: pokedexList))
                    completion(true)
                } else {
                    print("PokedexListService: Error fetching Pokedex from API")
                    completion(true)
                }
            })
        } else {
            print("PokedexListService: Pokedex fetched from CoreData")
            store.dispatch(UpdatePokedexListAction(list: pokedexList))
            completion(true)
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Save object to Core Data Methods
    
    func createPokedexFromJSON(_ JSON: [String: Any], _ objectContext: NSManagedObjectContext) {
        let list = JSON["results"] as! Array<Dictionary<String, Any>>
        let context = PrivateMapContext(objectContext)
        for pokemonItem in list  {
            _ = Mapper<PokemonId>(context: context).map(JSON: pokemonItem)
            try! objectContext.save()
            //print("Saving object PokemonId id=\(pokemon!.id)")
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Fetch Methods
    
    // -- Fetch from pokemon/limit?=802
    // Um request cria todos os objetos PokemonId :D
    func fetchPokedex(objectContext: NSManagedObjectContext, _ completion: @escaping (_ success: Bool) -> Void) {
        Alamofire.request((URL(string: root + "pokemon/?limit=" + String(pokedexSize)))!).responseJSON(completionHandler: { response in
            if (response.result.error != nil) {
                print(response.result.error!)
                completion(false)
                return
            }
            if let json = response.result.value as! [String: Any]? {
                self.createPokedexFromJSON(json, objectContext)
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
            completion(false)
        }
        
        // Create Directory "pokemon"
        try! FileManager.default.createDirectory(atPath: dirPath.relativePath, withIntermediateDirectories: true)
        
        //placeholder
        let spritePath = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + String(pokemonId) + ".png"
        
        // Fetch image from API
        let data:Data
        do {
            data = try Data(contentsOf: URL(string: spritePath)!)
        } catch {
            print("PokedexListService: error fetching image")
            return
        }
        let image = UIImage(data: data, scale: UIScreen.main.scale)!
        let pngImage = UIImagePNGRepresentation(image)
        
        // Save image locally
        try! pngImage?.write(to: filePath, options: .atomic)
        //print("Saving Sprite for id=" + String(pokemonId))
        completion(true)
    }
    
    private var typeIndex = 1
    
    func fetchTypes(_ id: Int, completion: @escaping (_ success: Bool) -> Void) {
        let url = URL(string: root)?.appendingPathComponent("type").appendingPathComponent(String(id)).appendingPathComponent("/")
        Alamofire.request(url!).responseJSON(completionHandler: { response in
            if (response.result.error != nil) {
                print(response.result.error!)
                completion(false)
                return
            }
            if let json = response.result.value as! [String: Any]? {
                _ = Mapper<Type>(context: PrivateMapContext(context)).map(JSON: json)
                try! context.save()
                //print("PokedexListService: Fetched and saved Type id=\(type!.id) name=\(type!.name!)")
                if self.typeIndex < self.typesSize {
                    self.typeIndex += 1
                    self.fetchTypes(self.typeIndex, completion: { success in
                        if success {
                            completion(true)
                        }
                    })
                } else {
                    //print("PokedexListService: fetched all types from API")
                    completion(true)
                }
            }
        })
    }
    
    private var genIndex = 1
    
    func fetchGenerations(_ id: Int, completion: @escaping (_ success: Bool) -> Void) {
        let url = URL(string: root)?.appendingPathComponent("generation").appendingPathComponent(String(id)).appendingPathComponent("/")
        Alamofire.request(url!).responseJSON(completionHandler: { response in
            if (response.result.error != nil) {
                print(response.result.error!)
                completion(false)
                return
            }
            if let json = response.result.value as! [String: Any]? {
                _ = Mapper<Generation>(context: PrivateMapContext(context)).map(JSON: json)
                try! context.save()
                //print("PokedexListService: Fetched and saved Generation id=\(gen?.id) name=\(gen?.name!)")
                if self.genIndex < self.gensSize {
                    self.genIndex += 1
                    self.fetchGenerations(self.genIndex, completion: { success in
                        if success {
                            completion(true)
                        }
                    })
                } else {
                    //print("PokedexListService: fetched all generation from API")
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
