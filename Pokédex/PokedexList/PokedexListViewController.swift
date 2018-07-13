//
//  PokedexListViewController.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import UIKit
import CoreData
import ObjectMapper
import ReSwift

class PokedexListTableCell: UITableViewCell {
    @IBOutlet weak var spriteImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
}

class PokedexListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StoreSubscriber {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var pokedexList = [PokemonId]()
    var typesList = [Type]()
    var filteredPokedexList = [PokemonId]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        view.addSubview(barView)
        navBar.barTintColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        
        setUpSearchController()
    }
    
    func setUpSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokemon by name"
        tableView.tableHeaderView = searchController.searchBar
        self.tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subcription in
            subcription
                .select { state in (state.pokedexListState) }
            //.skip(when: { pokedexListState in pokedexList.isEmpty })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    func newState(state: PokedexListState) {
        if (!store.state.pokedexListState.pokedexList.isEmpty && store.state.pokedexListState.pokedexList != self.pokedexList) {
            self.pokedexList = store.state.pokedexListState.pokedexList
            tableView.reloadData()
        }
        if !store.state.pokedexListState.filteredPokedexList.isEmpty {
            self.filteredPokedexList = store.state.pokedexListState.filteredPokedexList
            self.tableView.reloadData()
        }
        if !store.state.pokedexListState.typesList.isEmpty {
            self.typesList = store.state.pokedexListState.typesList
            self.tableView.reloadData()
        }
    }
    
    typealias StoreSubscriberStateType = PokedexListState
    
    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPokedexList.count
        }
        return self.pokedexList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokedexListTableCell")! as! PokedexListTableCell

        let poke: PokemonId
        if isFiltering() {
            poke = filteredPokedexList[indexPath.row]
        } else {
            poke = pokedexList[indexPath.row]
        }

        // Fetch pokemon sprite
        PokedexListServices.shared.fetchSprite(pokemonId: Int(poke.id)) { result in
            if result {
                cell.reloadInputViews()
            } else {
                cell.spriteImageView?.image = UIImage(contentsOfFile: PokedexListServices.shared.spritePath.appendingPathComponent(String(poke.id)).relativePath)
            }
        }

        cell.nameLabel?.text = poke.name?.capitalized
        cell.spriteImageView?.image = UIImage(contentsOfFile: PokedexListServices.shared.spritePath.appendingPathComponent(String(poke.id)).relativePath)
        
        return cell
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Private instance methods
    
    func isFiltering() -> Bool {
        return (searchController.isActive && !searchBarIsEmpty()) || store.state.pokedexListState.isFiltering
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        let filteredPokemon = pokedexList.filter({( pokemon : PokemonId) -> Bool in
            return (pokemon.name?.lowercased().contains(searchText.lowercased()))!
        })
        store.dispatch(UpdateFilteredListAction(list: filteredPokemon))
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if let indexPath = tableView.indexPathForSelectedRow {
            let poke: PokemonId
            if isFiltering() {
                poke = filteredPokedexList[(indexPath as NSIndexPath).row]
            } else {
                poke = pokedexList[(indexPath as NSIndexPath).row]
            }
            store.dispatch(SelectPokemonIdAction(selectedPokemonId: poke))
            if searchController.isActive == true {
                self.searchController.dismiss(animated: false)
            }
        }
    }
}

extension PokedexListViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

