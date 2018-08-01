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
import ReSwift
import PromiseKit

class PokedexListService {
    
    // MARK: Properties
    // API
    let pokedexSize:Int = 802
    let typesSize:Int = 18
    let gensSize: Int = 7
    let root:String = "http://pokeapi.co/api/v2/"
    let sprite:String = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
    
    // Other
    enum PokedexListServiceError: Error {
        case JSONError
        case PathError
    }
    var serviceStore: Store<AppState>
    let spritePath:URL = PokedexListService.getDocumentsDirectory().appendingPathComponent("pokemon")

    static let shared = PokedexListService(serviceStore: store)
    
    init(serviceStore: Store<AppState>) {
        self.serviceStore = serviceStore
    }

    func loadData(completion: @escaping (_ success: Bool) -> Void) {
        startPokemon()
        firstly {
            startPokedex()
        }.then { _ in
            self.startTypes()
        }.then { _ in
            self.startGenerations()
        }.done { _ in
            completion(true)
        }.catch { _ in
            print("PokedexListService: Error loading data")
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Init Pokemon, PokemonId, Type Objects
    
    func startPokemon() {
        // Try and fetch Pokemon from CoreData
        var pokedexInfo: [Pokemon] = []
        let fetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let pokedexFetched = try context.fetch(fetchRequest)
            pokedexInfo = pokedexFetched
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        print("PokedexListService: fetched \(pokedexInfo.count) Pokemon from CoreData")
        serviceStore.dispatch(SetPokemonInfoList(list: pokedexInfo))
    }
    
    func startPokedex() -> Promise<Bool> {
        return Promise<Bool> { seal in
            var pokedex: [PokemonId] = fetch(entityName: "PokemonId") as! [PokemonId]
            
            // If not found in CoreData, fetch from API and save in CoreData
            if pokedex.count < pokedexSize {
                fetchPokedex(objectContext: context).done { _ in
                    print("PokedexListService: Pokedex fetched from API")
                    pokedex = self.fetch(entityName: "PokemonId") as! [PokemonId]
                    self.serviceStore.dispatch(UpdatePokedexListAction(list: pokedex))
                    self.serviceStore.dispatch(UpdateFilteredListAction(list: pokedex))
                    seal.fulfill(true)
                }.catch { _ in
                    print("PokedexListService: Error fetching Pokedex from API")
                    seal.fulfill(true)
                }
            } else {
                print("PokedexListService: Pokedex fetched from CoreData")
                serviceStore.dispatch(UpdatePokedexListAction(list: pokedex))
                serviceStore.dispatch(UpdateFilteredListAction(list: pokedex))
                seal.fulfill(true)
            }
        }
    }
    
    func startTypes() -> Promise<Bool> {
        // Try and fetch Type from CoreData
        return Promise<Bool> { seal in
            var typesList:[Type] = fetch(entityName: "Type") as! [Type]
            
            // If not found in CoreData, fetch from API and save in CoreData
            if typesList.count < typesSize {
                fetchTypes().done { _ in
                    print("PokedexListService: Types fetched from API")
                    typesList = self.fetch(entityName: "Type") as! [Type]
                    self.serviceStore.dispatch(UpdateTypesListAction(list: typesList))
                    seal.fulfill(true)
                }.catch { _ in
                    print("PokedexListService: Error fetching types from API")
                    seal.fulfill(true)
                }
            } else {
                print("PokedexListService: Types fetched from CoreData")
                serviceStore.dispatch(UpdateTypesListAction(list: typesList))
                seal.fulfill(true)
            }
        }
    }
    
    func startGenerations() -> Promise<Bool> {
        // Try and fetch Generations from CoreData
        return Promise<Bool> { seal in
            var generations: [Generation] = fetch(entityName: "Generation") as! [Generation]
            
            // If not found in CoreData, fetch from API and save in CoreData
            if generations.count < gensSize {
                fetchGenerations().done { _ in
                    print("PokedexListService: Generations fetched from API")
                    generations = self.fetch(entityName: "Generation") as! [Generation]
                    self.serviceStore.dispatch(UpdateGenListAction(list: generations))
                    seal.fulfill(true)
                }.catch { _ in
                        print("PokedexListService: Error fetching types from API")
                        seal.fulfill(true)
                }
            } else {
                print("PokedexListService: Generations fetched from CoreData")
                serviceStore.dispatch(UpdateGenListAction(list: generations))
                seal.fulfill(true)
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Save object to Core Data Methods
    
    func createPokedexFromJSON(_ JSON: [String: Any], _ objectContext: NSManagedObjectContext) {
        let list = JSON["results"] as! Array<Dictionary<String, Any>>
        let privateContext = PrivateMapContext(objectContext)
        for pokemonItem in list  {
            _ = Mapper<PokemonId>(context: privateContext).map(JSON: pokemonItem)
            try! objectContext.save()
        }
    }
    
    func createTypeFromJSON(_ JSON: [String: Any], _ objectContext: NSManagedObjectContext) {
        let type = Mapper<Type>(context: PrivateMapContext(objectContext)).map(JSON: JSON)
        type?.fetchPokemon(objectContext)
        try! context.save()
    }
    
    func createGenerationFromJSON(_ JSON: [String: Any], _ objectContext: NSManagedObjectContext) {
        let gen = Mapper<Generation>(context: PrivateMapContext(objectContext)).map(JSON: JSON)
        gen?.fetchPokemon(objectContext)
        try! context.save()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Fetch from CoreData Method
    
    func fetch(entityName: String) -> [Any] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            let fetched = try context.fetch(fetchRequest)
            return fetched
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return []
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Fetch from API Methods
    
    // -- Fetch from pokemon/limit?=802
    // Um request cria todos os objetos PokemonId :D
    func fetchPokedex(objectContext: NSManagedObjectContext) -> Promise<Bool> {
        return Promise<Bool> { seal in
            guard let url = URL(string: root + "pokemon/?limit=" + String(pokedexSize)) else {
                seal.reject(PokedexListServiceError.PathError)
                return
            }
            Alamofire.request(url).responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    guard let json = response.result.value as! [String: Any]? else {
                        seal.reject(PokedexListServiceError.JSONError)
                        return
                    }
                    self.createPokedexFromJSON(json, objectContext)
                    seal.fulfill(true)
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
            })
            
        }
    }
    
    func fetchTypes()  -> Promise<[Bool]> {
        let typesIndex: [Int] = Array(1...typesSize)
        return when(fulfilled: typesIndex.map { index in
            return Promise<Bool> { seal in
                guard let url = URL(string: root)?.appendingPathComponent("type").appendingPathComponent(String(index)) else {
                    seal.reject(PokedexListServiceError.PathError)
                    return
                }
                Alamofire.request(url).responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success:
                        guard let json = response.result.value as! [String: Any]? else {
                            seal.reject(PokedexListServiceError.JSONError)
                            return
                        }
                        self.createTypeFromJSON(json, context)
                        seal.fulfill(true)
                    case .failure(let error):
                        print(error)
                        seal.reject(error)
                    }
                })
            }
        })
    }
    
    func fetchGenerations()  -> Promise<[Bool]> {
        let generationsIndex: [Int] = Array(1...gensSize)
        return when(fulfilled: generationsIndex.map { index in
            return Promise<Bool> { seal in
                guard let url = URL(string: root)?.appendingPathComponent("generation").appendingPathComponent(String(index)) else {
                    seal.reject(PokedexListServiceError.PathError)
                    return
                }
                Alamofire.request(url).responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success:
                        guard let json = response.result.value as! [String: Any]? else {
                            seal.reject(PokedexListServiceError.JSONError)
                            return
                        }
                        self.createGenerationFromJSON(json, context)
                        seal.fulfill(true)
                    case .failure(let error):
                        print(error)
                        seal.reject(error)
                    }
                })
            }
        })
    }
    
    // -- Fetch Sprite from API
    func fetchSprite(pokemonId: Int, completion: (_ success: Bool) -> Void) {
        let dirPath = PokedexListService.getDocumentsDirectory().appendingPathComponent("pokemon")
        let filePath = dirPath.appendingPathComponent(String(pokemonId) + ".png")
        guard !FileManager.default.fileExists(atPath: filePath.relativePath) else {
            completion(false)
            return
        }
        try! FileManager.default.createDirectory(atPath: dirPath.relativePath, withIntermediateDirectories: true)
        guard let spriteURL = URL(string: sprite + String(pokemonId) + ".png") else {
            completion(false)
            return
        }
        let data:Data
        do {
            data = try Data(contentsOf: spriteURL)  // Fetch image from API
        } catch {
            print("PokedexListService: error fetching image")
            completion(false)
            return
        }
        let image = UIImage(data: data, scale: UIScreen.main.scale)!
        let pngImage = UIImagePNGRepresentation(image)
        
        do {
            try pngImage?.write(to: filePath, options: .atomic)
        } catch {
            print("PokedexListService: error fetching image")
            completion(false)
            return
        }
        //print("Saving Sprite for id=" + String(pokemonId))
        completion(true)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Helper Methods
    
    // Return path for Documents
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
