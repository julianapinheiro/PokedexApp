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
    
    var isFiltering = false
    var isSearching = false
    var pokedexList = [PokemonId]()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subcription in
            subcription
                .select { state in state.pokedexListState }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    func setUpSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokémon by name"
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        self.tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
        definesPresentationContext = true
    }
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    func newState(state: PokedexListState) {
        self.pokedexList = state.pokedexList
        self.filteredPokedexList = state.filteredPokedexList
        self.isFiltering = state.isFiltering
        self.isSearching = state.isSearching
        self.tableView.reloadData()
    }
    
    typealias StoreSubscriberStateType = PokedexListState
    
    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching || isFiltering {
            return filteredPokedexList.count
        }
        return pokedexList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokedexListTableCell")! as! PokedexListTableCell

        let poke: PokemonId
        if isSearching || isFiltering {
            poke = filteredPokedexList[indexPath.row]
        } else {
            poke = pokedexList[indexPath.row]
        }

        // Fetch pokemon sprite
        PokedexListService.shared.fetchSprite(pokemonId: Int(poke.id)) { result in
            if result {
                cell.reloadInputViews()
            } else {
                cell.spriteImageView?.image = UIImage(contentsOfFile: PokedexListService.shared.spritePath.appendingPathComponent(String(poke.id)).relativePath)
            }
        }

        cell.nameLabel?.text = poke.name?.capitalized
        cell.spriteImageView?.image = UIImage(contentsOfFile: PokedexListService.shared.spritePath.appendingPathComponent(String(poke.id)).relativePath)
        
        return cell
    }
    
    // -------------------------------------------------------------------------
    // MARK: - SearchBar
    
    func filterContentForSearchText(_ searchText: String) {
        store.dispatch(SetSearchWordAction(searchWord: searchText))
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if let indexPath = tableView.indexPathForSelectedRow {
            let poke: PokemonId
            if isSearching || isFiltering {
                poke = filteredPokedexList[(indexPath as NSIndexPath).row]
            } else {
                poke = pokedexList[(indexPath as NSIndexPath).row]
            }
            store.dispatch(SelectPokemonIdAction(pokemon: poke))
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

extension PokedexListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        store.dispatch(SetIsSearchingAction(isSearching: true))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        store.dispatch(SetIsSearchingAction(isSearching: false))
        self.tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
        definesPresentationContext = true
    }
}
