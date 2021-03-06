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
    
    // MARK: IBOutlets
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    var typesList = [Type?]()
    var genList = [Generation?]()
    var selectedType: Type? = nil
    var selectedGen: Generation? = nil
    
    // -------------------------------------------------------------------------
    // MARK: - ViewController lifecycle methods
    
    override func viewDidLoad() {
        setLoadingIndicator(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subcription in
            subcription
                .select { state in (state.pokedexListState) }
        }
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - UI methods
    
    func setupUI() {
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        view.addSubview(barView)
        navBar.barTintColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
    }
    
    func setLoadingIndicator(_ start: Bool) {
        loadingIndicator.isHidden = !start
        if start {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    
    func newState(state: PokedexListState) {
        if !store.state.pokedexListState.typesList.isEmpty {
            typesList = store.state.pokedexListState.typesList
            typesList.insert(nil, at: 0)
            tableView.reloadData()
        }
        if !store.state.pokedexListState.genList.isEmpty {
            genList = store.state.pokedexListState.genList
            genList.insert(nil, at: 0)
            tableView.reloadData()
        }
        selectedType = store.state.pokedexListState.typeScope
        selectedGen = store.state.pokedexListState.genScope
    }
    
    typealias StoreSubscriberStateType = PokedexListState
    
    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return typesList.count
        case 1:
            return genList.count
        default:
            return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int) -> String?
    {
        switch section {
        case 0:
            return "By Type"
        case 1:
            return "By Generation"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortTableViewCell")!
        switch (indexPath.section) {
        case 0:
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
        case 1:
            if genList[indexPath.row] == nil {
                cell.textLabel?.text = "All"
            } else {
                cell.textLabel?.text = genList[indexPath.row]!.name?.capitalized.replacingOccurrences(of: "-", with: " ")
            }
            if genList[indexPath.row] == selectedGen {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        default:
            cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            setLoadingIndicator(true)
            store.dispatch(SetTypeScopeAction(type: typesList[(indexPath as NSIndexPath).row]))
            dismiss(animated: true, completion: nil)
        case 1:
            setLoadingIndicator(true)
            store.dispatch(SetGenScopeAction(gen: genList[(indexPath as NSIndexPath).row]))
            dismiss(animated: true, completion: nil)
        default:
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    // -------------------------------------------------------------------------
    // MARK: - IBActions
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
