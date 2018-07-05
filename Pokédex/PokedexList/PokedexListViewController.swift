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
    
    var dataController:DataController!
    
    func newState(state: PokedexListState) {
        tableView.reloadData()
    }
    
    typealias StoreSubscriberStateType = PokedexListState
    
    override func viewDidLoad() {
        super.viewDidLoad()

        store.subscribe(self) { state in
            state.select { state in (state.pokedexListState) }
        }
        
        // UI Setup
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor(red:0.98, green:0.78, blue:0.78, alpha:1.0)
        view.addSubview(barView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Table view data source
    
    // errr
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (store.state.pokedexListState.pokedexList.count == 0) {
            //tableView.reloadData()
        }
        return store.state.pokedexListState.pokedexList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokedexListTableCell")! as! PokedexListTableCell
        let poke = store.state.pokedexListState.pokedexList[(indexPath as NSIndexPath).row]
        
        // Fetch pokemon sprite (if not saved yet)
        fetchSprite(pokemonId: Int(poke.id)) { result in
                tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        cell.nameLabel?.text = poke.name?.capitalized
        cell.spriteImageView?.image = UIImage(contentsOfFile: spritePath.appendingPathComponent(String(poke.id)).relativePath)
        
        return cell
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if let indexPath = tableView.indexPathForSelectedRow {
            store.dispatch(SelectPokemonIdAction(selectedPokemonId: store.state.pokedexListState.pokedexList[(indexPath as NSIndexPath).row]))
        }
    }
}

