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
    let pokedexListService = PokedexListService.shared
    var dataController:DataController!
    var complete = 0

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pokedexListService.startPokemon()
        pokedexListService.startPokedex(completion: { success in
            if success {
                self.pokedexListService.startTypes(completion: { success in
                    if success {
                        self.loadNextView()
                    }
                })
            }
        })
    }
    
    func loadNextView() {
        let storyboard = UIStoryboard(name: "PokedexList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "PokedexListViewController") as! PokedexListViewController
        present(mainViewController, animated: true, completion: nil)
    }


}

