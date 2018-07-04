//
//  PokedexListViewController.swift
//  Pokédex
//
//  Created by Juliana on 29/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import ObjectMapper

class PokedexListTableCell: UITableViewCell {
    @IBOutlet weak var spriteImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
}

class PokedexListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pokemon:[Pokemon]!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pokemon>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokemon = []
        
        setUpFetchedResultsController()

        fetchPokedex()

        for index in 11...40 {
            fetchPokemon(id: index, completion: { success in
                self.tableView.reloadData()
            })
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //fetchedResultsController = nil
    }
    
    // temporary populate
    func fetchPokedex() {
        var poke = Pokemon(context: dataController.viewContext)
        poke.name = "Oshawott"
        poke.id = 501
        pokemon.append(poke)
        poke = Pokemon(context: dataController.viewContext)
        poke.name = "Pignite"
        poke.id = 499
        pokemon.append(poke)
        try? dataController.viewContext.save()
    }
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pokemons")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Table view data source
    
    // errr
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokedexListTableCell")! as! PokedexListTableCell
        let poke = fetchedResultsController.object(at: indexPath)
        
        //fetch()
        
        // Fetch pokemon sprite (if not saved yet)
        fetchSprite(pokemonId: Int(poke.id)) { result in
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        // Set the name and image
        cell.nameLabel?.text = poke.name?.capitalized
        cell.spriteImageView?.image = UIImage(contentsOfFile: spritePath.appendingPathComponent(String(poke.id)).relativePath) //image
        
        return cell
    }
    
}

extension PokedexListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
