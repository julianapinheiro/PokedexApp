//
//  PokedexCoreDataTests.swift
//  PokédexTests
//
//  Created by Juliana on 16/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import XCTest
import CoreData
@testable import Poke_dex
@testable import Alamofire

class PokedexCoreDataTests: XCTestCase {
    
    var sut: DataController!
    
    override func setUp() {
        super.setUp()
        sut = DataController(container: mockPersistentContainer)
    }
    
    override func tearDown() {
        super.tearDown()
        flushData()
    }
    
    func testCreatingPokemonId() {
        let json = ["results": [
            ["name": "tester", "url":"https://pokeapi.co/api/v2/pokemon-species/1001/"],
            ["name": "testerEvo", "url":"https://pokeapi.co/api/v2/pokemon-species/1002/"],
            ["name": "testerEvo2", "url":"https://pokeapi.co/api/v2/pokemon-species/1003/"],
            ["name": "pokemon", "url":"https://pokeapi.co/api/v2/pokemon-species/1004/"],
            ["name": "pokemon", "url":"https://pokeapi.co/api/v2/pokemon-species/1005/"],]]
        
        PokedexListService.shared.createPokedexFromJSON(json, mockPersistentContainer.viewContext)
        
        let results = numberOfObjectsInPersistentStore("PokemonId")
        XCTAssertEqual(results, 5)
        for index in 1001...1005 {
            XCTAssertEqual(fetchPokemonIdInPersistentStore(index).id, Int16(index))
        }
    }
    
    func testCreatingPokemon() {
        let jsonDex = ["results": [
            ["name": "tester", "url":"https://pokeapi.co/api/v2/pokemon-species/1001/"],]]
        
        PokedexListService.shared.createPokedexFromJSON(jsonDex, mockPersistentContainer.viewContext)
        
        let json:[String:Any] = [
            "name": "tester",
             "id": Int16(1001),
             "height": Float(10),
             "weight": Float(10),
             "color": ["url":"", "name": "red"],
             "types": [
                ["slot": 1, "type": ["name": "testerType", "url": ""] ],
                ["slot": 2 , "type": ["name": "flying", "url": ""] ],
            ],
            "chain": [ "evolves_to": [
                ["species": ["name": "testerEvo", "url":"https://pokeapi.co/api/v2/pokemon-species/1002/"], "evolves_to": []],
                 ["species": ["name": "testerEvo2", "url":"https://pokeapi.co/api/v2/pokemon-species/1003/"], "evolves_to": []]
                ], "species": ["name": "tester", "url":"https://pokeapi.co/api/v2/pokemon-species/1001/"] ],
            "pokedex_numbers": [
                ["entry_number": 1001, "pokedex": ["name": "unova", "url": ""] ]
            ],
             "flavor_text_entries": [
                ["flavor_text": "Pokemon flavor text", "language": ["name": "en", "url": ""], "version": ["name": "alpha-sapphire", "url": ""] ]
            ],
        ]
        
        PokemonInfoService.shared.createPokemonFromJSON(id: 1001, json, mockPersistentContainer.viewContext)
        
        let results = numberOfObjectsInPersistentStore("Pokemon")
        let pokemon = fetchPokemonInPersistentStore(1001)
        XCTAssertEqual(results, 1)
        XCTAssertEqual(pokemon.id, 1001)
        XCTAssertEqual(pokemon.name, "tester")
        XCTAssertEqual(pokemon.height, 1)
        XCTAssertEqual(pokemon.color, "red")
        XCTAssertEqual(pokemon.types!, ["testerType", "flying"])
        XCTAssertEqual(pokemon.evolutionChain!, [1001, 1002, 1003])
        XCTAssertEqual(pokemon.indexes!, ["unova": "1001"])
        XCTAssertEqual(pokemon.text_entry!, "Pokemon flavor text")
    }
    
    func testCreatingType() {
        let jsonDex = ["results": [
            ["name": "tester", "url":"https://pokeapi.co/api/v2/pokemon-species/1001/"],
            ["name": "testerEvo", "url":"https://pokeapi.co/api/v2/pokemon-species/1002/"]]]
        
        PokedexListService.shared.createPokedexFromJSON(jsonDex, mockPersistentContainer.viewContext)
        
        let json:[String:Any] = [
            "name": "testerType",
            "id": Int16(20),
            "pokemon": [
                ["slot": 1, "pokemon": ["name": "tester", "url":"https://pokeapi.co/api/v2/pokemon/1001/"] ],
                ["slot": 1 , "pokemon": ["name": "testerEvo", "url":"https://pokeapi.co/api/v2/pokemon/1002/"] ],
            ],
            ]
        
        PokedexListService.shared.createTypeFromJSON(json, mockPersistentContainer.viewContext)
        
        let results = numberOfObjectsInPersistentStore("Type")
        let type = fetchTypeInPersistentStore(20)
        XCTAssertEqual(results, 1)
        XCTAssertEqual(type.id, 20)
        XCTAssertEqual(type.name, "testerType")
        XCTAssertEqual(type.pokemonList?.count, 2)
        for pokemon in Array(type.pokemonList!) as! Array<PokemonId> {
            let result = pokemon.name! == fetchPokemonIdInPersistentStore(1001).name! || pokemon.name! == fetchPokemonIdInPersistentStore(1002).name!
            XCTAssertTrue(result)
        }
        
        
    }

    func testCreatingGeneration() {
        let jsonDex = ["results": [
            ["name": "tester", "url":"https://pokeapi.co/api/v2/pokemon-species/1001/"],
            ["name": "testerEvo", "url":"https://pokeapi.co/api/v2/pokemon-species/1002/"]]]
        
        PokedexListService.shared.createPokedexFromJSON(jsonDex, mockPersistentContainer.viewContext)
        
        let json:[String:Any] = [
            "name": "generation-x",
            "id": Int16(10),
            "pokemon_species": [
                [ "name": "tester", "url":"https://pokeapi.co/api/v2/pokemon/1001/" ],
                [ "name": "testerEvo", "url":"https://pokeapi.co/api/v2/pokemon/1002/" ],
            ],
            ]
        
        PokedexListService.shared.createGenerationFromJSON(json, mockPersistentContainer.viewContext)
        
        let results = numberOfObjectsInPersistentStore("Generation")
        let gen = fetchGenerationInPersistentStore(10)
        XCTAssertEqual(results, 1)
        XCTAssertEqual(gen.id, 10)
        XCTAssertEqual(gen.name, "generation-x")
        XCTAssertEqual(gen.pokemonList?.count, 2)
        for pokemon in Array(gen.pokemonList!) as! Array<PokemonId> {
            let result = pokemon.name! == fetchPokemonIdInPersistentStore(1001).name! || pokemon.name! == fetchPokemonIdInPersistentStore(1002).name!
            XCTAssertTrue(result)
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - In Memory PersitentContainer
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    lazy var mockPersistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "PersistentTodoList", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()
    
}

extension PokedexCoreDataTests {
    
    func flushData() {
        
        var fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonId")
        var objs = try! mockPersistentContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistentContainer.viewContext.delete(obj)
        }
        
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pokemon")
        objs = try! mockPersistentContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistentContainer.viewContext.delete(obj)
        }
        
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Type")
        objs = try! mockPersistentContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistentContainer.viewContext.delete(obj)
        }
        
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Generation")
        objs = try! mockPersistentContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistentContainer.viewContext.delete(obj)
        }
        
        try! mockPersistentContainer.viewContext.save()
        
    }
    
    func numberOfObjectsInPersistentStore(_ entityName: String) -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let results = try! mockPersistentContainer.viewContext.fetch(request)
        return results.count
    }
    
    func fetchPokemonIdInPersistentStore(_ id: Int) -> PokemonId {
        let request: NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
        request.predicate = NSPredicate(format: "id = %x", id)
        let results = try! mockPersistentContainer.viewContext.fetch(request)
        return results[0]
    }
    
    func fetchPokemonInPersistentStore(_ id: Int) -> Pokemon {
        let request: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        request.predicate = NSPredicate(format: "id = %x", id)
        let results = try! mockPersistentContainer.viewContext.fetch(request)
        return results[0]
    }
    
    func fetchTypeInPersistentStore(_ id: Int) -> Type {
        let request: NSFetchRequest<Type> = Type.fetchRequest()
        request.predicate = NSPredicate(format: "id = %x", id)
        let results = try! mockPersistentContainer.viewContext.fetch(request)
        return results[0]
    }
    
    func fetchGenerationInPersistentStore(_ id: Int) -> Generation {
        let request: NSFetchRequest<Generation> = Generation.fetchRequest()
        request.predicate = NSPredicate(format: "id = %x", id)
        let results = try! mockPersistentContainer.viewContext.fetch(request)
        return results[0]
    }

}
