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

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startPokedex()
        activityIndicator.startAnimating()
    }
    
    func startPokedex() {
        // Try and fetch PokemonId from CoreData
        let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
        var sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var pokedexList = try! context.fetch(fetchRequest)
        
        // If not found in CoreData, fetch from API and save in CoreData
        if pokedexList.isEmpty {
            fetchPokedex {success in
                if success {
                    print("Pokedex fetched from API")
                    pokedexList = try! context.fetch(fetchRequest)
                    store.dispatch(UpdateListAction(list: pokedexList))
                }
            }
        }
        print("Pokedex fetched from CoreData")
        store.dispatch(UpdateListAction(list: pokedexList))
        
        // Try and fetch Pokemon Info from CoreData
        let listFetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        listFetchRequest.sortDescriptors = [sortDescriptor]
        
        let pokedexInfoList = try! context.fetch(listFetchRequest)
        store.dispatch(SetPokemonInfoList(list: pokedexInfoList))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let storyboard = UIStoryboard(name: "PokedexList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "PokedexListViewController") as! PokedexListViewController
        mainViewController.dataController = self.dataController
        present(mainViewController, animated: true, completion: nil)
    }


}

