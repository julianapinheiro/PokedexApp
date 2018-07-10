//
//  ViewController.swift
//  Pokédex
//
//  Created by Juliana on 27/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var dataController:DataController!
    var complete = 0

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    func startPokedex() {
        // Try and fetch PokemonId from CoreData
        let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var pokedexList = try! context.fetch(fetchRequest)
        
        // If not found in CoreData, fetch from API and save in CoreData
        if pokedexList.isEmpty {
            fetchPokedex {success in
                if success {
                    print("ViewController: Pokedex fetched from API")
                    pokedexList = try! context.fetch(fetchRequest)
                    store.dispatch(UpdateListAction(list: pokedexList))
                    self.startTypes()
                }
            }
        } else {
            startTypes()
            print("ViewController: Pokedex fetched from CoreData")
            store.dispatch(UpdateListAction(list: pokedexList))
        }
    }
    
    func startPokemon() {
        // Try and fetch Pokemon Info from CoreData
        let listFetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        listFetchRequest.sortDescriptors = [sortDescriptor]
        
        let pokedexInfoList = try! context.fetch(listFetchRequest)
        store.dispatch(SetPokemonInfoList(list: pokedexInfoList))
    }
    
    func startTypes() {
        // Try and fetch Type from CoreData
        let fetchRequest:NSFetchRequest<Type> = Type.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var typesList = try! context.fetch(fetchRequest)
        
        // If not found in CoreData, fetch from API and save in CoreData
        if typesList.isEmpty {
            self.complete = 0
            for index in 1...1 {
                print("Fetching type = \(index)")
                fetchType(index, completion: { success in
                    if success {
                        print("ViewController: Types fetched from API")
                        typesList = try! context.fetch(fetchRequest)
                        store.dispatch(UpdateTypesListAction(list: typesList))
                        self.loadNextView()
                    }
                })
            }
            //while complete != typesSize {}
            print("ViewController: Types fetched from API")
            typesList = try! context.fetch(fetchRequest)
            store.dispatch(UpdateTypesListAction(list: typesList))
            self.loadNextView()
        } else {
            loadNextView()
            print("ViewController: Types fetched from CoreData")
            store.dispatch(UpdateTypesListAction(list: typesList))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startPokemon()
        startPokedex()
    }
    
    func loadNextView() {
        let storyboard = UIStoryboard(name: "PokedexList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "PokedexListViewController") as! PokedexListViewController
        present(mainViewController, animated: true, completion: nil)
    }


}

