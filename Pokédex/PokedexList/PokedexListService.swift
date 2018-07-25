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
    
    // API Info
    let pokedexSize:Int = 802
    let typesSize:Int = 18
    let gensSize: Int = 7
    let root:String = "http://pokeapi.co/api/v2/"
    let spritePath:URL = PokedexListService.getDocumentsDirectory().appendingPathComponent("pokemon")
    enum PokedexListServiceError: Error {
        case JSONError
    }
    
    // Store
    var serviceStore: Store<AppState>
    
    init(serviceStore: Store<AppState>) {
        self.serviceStore = serviceStore
    }
    
    static let shared = PokedexListService(serviceStore: store)
    
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
        // Try and fetch PokemonId from CoreData
        return Promise<Bool> { seal in
            var pokedex: [PokemonId] = []
            let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                let pokedexFetched = try context.fetch(fetchRequest)
                pokedex = pokedexFetched
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            // If not found in CoreData, fetch from API and save in CoreData
            if pokedex.count < pokedexSize {
                fetchPokedex(objectContext: context).done { _ in
                    print("PokedexListService: Pokedex fetched from API")
                    do {
                        let pokedexFetched = try context.fetch(fetchRequest)
                        pokedex = pokedexFetched
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
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
                self.serviceStore.dispatch(UpdateFilteredListAction(list: pokedex))
                seal.fulfill(true)
            }
        }
    }
    
    func startTypes() -> Promise<Bool> {
        // Try and fetch Type from CoreData
        return Promise<Bool> { seal in
            var typesList:[Type] = []
            let fetchRequest:NSFetchRequest<Type> = Type.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                let typesFetched = try context.fetch(fetchRequest)
                typesList = typesFetched
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            // If not found in CoreData, fetch from API and save in CoreData
            if typesList.count < typesSize {
                fetchTypes(1).done { _ in
                    print("PokedexListService: Types fetched from API")
                    do {
                        let typesFetched = try context.fetch(fetchRequest)
                        typesList = typesFetched
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
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
            var generations: [Generation] = []
            let fetchRequest:NSFetchRequest<Generation> = Generation.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            do{
                let gensFetched = try context.fetch(fetchRequest)
                generations = gensFetched
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            // If not found in CoreData, fetch from API and save in CoreData
            if generations.count < gensSize {
                fetchGenerations(1).done { _ in
                    print("PokedexListService: Generations fetched from API")
                    do {
                        let gensFetched = try context.fetch(fetchRequest)
                        generations = gensFetched
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
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
            //print("Saving object PokemonId id=\(pokemon!.id)")
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
    // MARK: - Fetch Methods
    
    // -- Fetch from pokemon/limit?=802
    // Um request cria todos os objetos PokemonId :D
    func fetchPokedex(objectContext: NSManagedObjectContext) -> Promise<Bool> {
        return Promise<Bool> { seal in
            guard let url = URL(string: root + "pokemon/?limit=" + String(pokedexSize)) else {
                seal.fulfill(false)
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
    
    private var typeIndex = 1
    
    func fetchTypes(_ id: Int) -> Promise<Bool> {
        return Promise<Bool> { seal in
            guard let url = URL(string: root)?.appendingPathComponent("type").appendingPathComponent(String(id)).appendingPathComponent("/") else {
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
                    //print("PokedexListService: Fetched and saved Type id=\(type!.id) name=\(type!.name!)")
                    if self.typeIndex < self.typesSize {
                        self.typeIndex += 1
                        self.fetchTypes(self.typeIndex).done { _ in
                            seal.fulfill(true)
                        }.catch { _ in
                                print("PokedexListService: Error fetching types from API")
                                seal.fulfill(true)
                        }
                    }
                    seal.fulfill(true)
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
            })
        }
    }
    
    private var genIndex = 1
    
    func fetchGenerations(_ id: Int)  -> Promise<Bool> {
        return Promise<Bool> { seal in
            guard let url = URL(string: root)?.appendingPathComponent("generation").appendingPathComponent(String(id)).appendingPathComponent("/") else {
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
                    //print("PokedexListService: Fetched and saved Type id=\(type!.id) name=\(type!.name!)")
                    if self.genIndex < self.gensSize {
                        self.genIndex += 1
                        self.fetchGenerations(self.genIndex).done { _ in
                            seal.fulfill(true)
                        }.catch { _ in
                            print("PokedexListService: Error fetching generations from API")
                            seal.fulfill(true)
                        }
                    }
                    seal.fulfill(true)
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
            })
        }
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
    
    // HELPER
    
    // Return path for Documents
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    

}
