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

let root:String = "http://pokeapi.co/api/v2/"
let spritePath:URL = getDocumentsDirectory().appendingPathComponent("pokemon")

var context = (UIApplication.shared.delegate as! AppDelegate).dataController.viewContext

func fetchCount(completion: @escaping (_ count: Int) -> Void) {
    let url = root + "pokemon-species/?limit=0"
    print(url)
    Alamofire.request(url).responseJSON(completionHandler: { response in
        if let json = response.result.value {
            let parsed = json as! [String : Any]
            let count = parsed["count"] as! Int
            completion(count)
        }
    })
}

let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])

func checkPokemon(id: Int) -> Bool {
    let fetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %d", id)
    let fetchedResults = try? context.fetch(fetchRequest)
    guard (fetchedResults?.isEmpty)! else {
        print("Pokemon already in Coredata id=" + String(id))
        return true
    }
    return false
}

func fetchPokemon(id: Int, completion: @escaping (_ success: Bool) -> Void) {
    if checkPokemon(id: id) {
        completion(true)
        return
    }
    print("Fetching pokemon from API id=" + String(id))
    Alamofire.request((URL(string: root + "pokemon/" + String(id)))!).responseJSON(completionHandler: { response in
        print("Did request")
        if let json = response.result.value {
            let poke = Pokemon(JSON: json as! [String : Any])
            context.insert(poke!)
            try! context.save()
            DispatchQueue.main.async {
                completion(true)
            }
        }
    })
    
}

/*func fetchPokedex() {
    fetchPokemon(id: 1, completion:  { result in
        print(result)
    })
    
}*/

// Fetch Sprite from API WORKING
func fetchSprite(pokemonId: Int, completion: (_ success: Bool) -> Void) {
    
    // If file already exists
    let dirPath = getDocumentsDirectory().appendingPathComponent("pokemon")
    let filePath = dirPath.appendingPathComponent(String(pokemonId) + ".png")
    if FileManager.default.fileExists(atPath: filePath.relativePath) {
        print("Pokemon Sprite already saved for id=" + String(pokemonId))
        return
    }
    
    // Create Directory "pokemon"
    try! FileManager.default.createDirectory(atPath: dirPath.relativePath, withIntermediateDirectories: true)
    
    //let pokemonURL = URL(string: root + "pokemon/" + String(describing: index))!
    //placeholder
    let spritePath = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + String(pokemonId) + ".png"
    
    // Fetch image from API
    let data = try! Data(contentsOf: URL(string: spritePath)!)
    let image = UIImage(data: data, scale: UIScreen.main.scale)!
    let pngImage = UIImagePNGRepresentation(image)
    
    // Save image locally
    try! pngImage?.write(to: filePath, options: .atomic)
    print("Saving Sprite for id=" + String(pokemonId))
    completion(true)
}

// HELPER

// Retorna path da pasta Documents
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

