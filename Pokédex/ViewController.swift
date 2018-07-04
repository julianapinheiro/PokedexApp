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
        let fetchRequest:NSFetchRequest<PokemonId> = PokemonId.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var pokedexList = try! context.fetch(fetchRequest)
        
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let storyboard = UIStoryboard(name: "PokedexList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "PokedexListViewController") as! PokedexListViewController
        mainViewController.dataController = self.dataController
        present(mainViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

