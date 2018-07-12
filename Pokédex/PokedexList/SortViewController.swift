//
//  SortViewController.swift
//  Pokédex
//
//  Created by Juliana on 12/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import ReSwift

class SortViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StoreSubscriber {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    var typesList = [Type?]()
    var selectedType: Type? = nil
    
    override func viewDidLoad() {
        // UI Setup
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        view.addSubview(barView)
        navBar.barTintColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subcription in
            subcription
                .select { state in (state.pokedexListState) }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    func newState(state: PokedexListState) {
        if !store.state.pokedexListState.typesList.isEmpty {
            self.typesList = store.state.pokedexListState.typesList
            self.typesList.insert(nil, at: 0)
            self.tableView.reloadData()
        }
        self.selectedType = store.state.pokedexListState.typeScope
    }
    
    typealias StoreSubscriberStateType = PokedexListState
    
    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortTableViewCell")!
        if typesList[indexPath.row] == nil {
            cell.textLabel?.text = "All"
        } else {
            cell.textLabel?.text = typesList[indexPath.row]!.name?.capitalized
        }
        if typesList[indexPath.row] == selectedType {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.dispatch(SetTypeScope(scope: typesList[(indexPath as NSIndexPath).row]))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
