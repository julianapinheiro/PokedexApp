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
    
    var pokedexList: [PokemonId]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        store.subscribe(self) { state in
            state.select { state in (state.pokedexListState) }
        }
        
        self.pokedexList = store.state.pokedexListState.pokedexList
        
        // UI Setup
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        view.addSubview(barView)
        navBar.barTintColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    func newState(state: PokedexListState) {
        if !store.state.pokedexListState.pokedexList.isEmpty {
            self.pokedexList = store.state.pokedexListState.pokedexList
            tableView.reloadData()
        }
    }
    
    typealias StoreSubscriberStateType = PokedexListState
    
    // -------------------------------------------------------------------------
    // MARK: - Table view data source
    
    // errr
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (store.state.pokedexListState.pokedexList.count == 0) {
            //tableView.reloadData()
        }
        return self.pokedexList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokedexListTableCell")! as! PokedexListTableCell
        let poke = self.pokedexList[(indexPath as NSIndexPath).row]
        
        // Fetch pokemon sprite (if not saved yet)
        fetchSprite(pokemonId: Int(poke.id)) { result in
            //tableView.reloadRows(at: [indexPath], with: .automatic) // crashes iPhone 5s
            cell.reloadInputViews() // doesn`t crash on 5s
        }

        cell.nameLabel?.text = poke.name?.capitalized
        cell.spriteImageView?.image = UIImage(contentsOfFile: spritePath.appendingPathComponent(String(poke.id)).relativePath)
        
        return cell
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if let indexPath = tableView.indexPathForSelectedRow {
            store.dispatch(SelectPokemonIdAction(selectedPokemonId: self.pokedexList[(indexPath as NSIndexPath).row]))
        }
    }
}

