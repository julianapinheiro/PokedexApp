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

let pokedexSize:Int = 802
let root:String = "http://pokeapi.co/api/v2/"
let spritePath:URL = getDocumentsDirectory().appendingPathComponent("pokemon")

// -- Fetch from pokemon/limit?=802
// Um request cria todos os objetos PokemonId :D
func fetchPokedex(completion: @escaping (_ success: Bool) -> Void) {
    Alamofire.request((URL(string: root + "pokemon/?limit=" + String(pokedexSize)))!).responseJSON(completionHandler: { response in
        if let json = response.result.value as! [String: Any]? {
            let pokemonList = json["results"] as! NSArray
            for pokemonItem in pokemonList  {
                savePokemon(pokemonItem as! Dictionary<String,Any>)
            }
            completion(true)
        }
    })
}

// -- Create and save PokemonId
// Salva nome e id em objeto PokemonId TODO: mappable object
func savePokemon(_ pokemonInfo:Dictionary<String,Any>) {
    let pokemon = PokemonId(context: context)
    pokemon.name = (pokemonInfo["name"] as? String)?.capitalized
    let url = URL(string: pokemonInfo["url"] as! String)
    pokemon.id = Int16((url?.pathComponents.last!)!)!
    context.insert(pokemon)
    try! context.save()
    print("Saving object PokemonId id=\(pokemon.id)")
}

// -- Fetch Sprite from API
func fetchSprite(pokemonId: Int, completion: (_ success: Bool) -> Void) {
    
    // If file already exists
    let dirPath = getDocumentsDirectory().appendingPathComponent("pokemon")
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

//todo
func fetchTypes(completion: @escaping (_ success: Bool) -> Void) {
    Alamofire.request((URL(string: root + "type/"))!).responseJSON(completionHandler: { response in
        if let json = response.result.value as! [String: Any]? {
            let typesList = json["results"] as! NSArray
            for typeItem in typesList  {
                let typeDict = typeItem as! [String: String]
            }
            completion(true)
        }
    })
}

// HELPER

// Retorna path da pasta Documents
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

