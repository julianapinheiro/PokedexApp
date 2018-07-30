//
//  ViewController.swift
//  Pokédex
//
//  Created by Juliana on 27/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import UIKit
import CoreData
import ReSwift

class ViewController: UIViewController, StoreSubscriber {
    
    // MARK: Properties
    let pokedexListService = PokedexListService.shared
    
    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    // -------------------------------------------------------------------------
    // MARK: - ViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subcription in
            subcription.select { state in (state.pokedexListState) }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadingLabel.text = "Fetching Pokédex..."
        pokedexListService.loadData { _ in
            self.loadNextView()
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    
    typealias StoreSubscriberStateType = PokedexListState
    
    func newState(state: PokedexListState) {
        if !state.pokedexList.isEmpty {
            loadingLabel.text = "Fetching Types..."
        }
        if !state.typesList.isEmpty {
            loadingLabel.text = "Fetching Generations..."
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Load View method
    
    func loadNextView() {
        let storyboard = UIStoryboard(name: "PokedexList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "PokedexListViewController") as! PokedexListViewController
        present(mainViewController, animated: true, completion: nil)
    }

}
