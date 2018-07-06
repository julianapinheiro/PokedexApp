//
//  PokemonInfoViewController.swift
//  Pokédex
//
//  Created by Juliana on 04/07/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class PokemonInfoViewController: UIViewController, StoreSubscriber {
    
    // -------------------------------------------------------------------------
    // MARK: - UI Outlets
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var spriteImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // Labels
    @IBOutlet weak var kantoLabel: UILabel!
    @IBOutlet weak var johtoLabel: UILabel!
    @IBOutlet weak var hoennLabel: UILabel!
    @IBOutlet weak var sinnohLabel: UILabel!
    @IBOutlet weak var unovaLabel: UILabel!
    @IBOutlet weak var kalosLabel: UILabel!
    @IBOutlet weak var heightValueLabel: UILabel!
    @IBOutlet weak var weightValueLabel: UILabel!
    
    // Pokedex numbers
    @IBOutlet weak var kantoIndex: UILabel!
    @IBOutlet weak var johtoIndex: UILabel!
    @IBOutlet weak var hoennIndex: UILabel!
    @IBOutlet weak var sinnohIndex: UILabel!
    @IBOutlet weak var unovaIndex: UILabel!
    @IBOutlet weak var kalosIndex: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var evoBarView: UIView!
    var barView: UIView!
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    typealias StoreSubscriberStateType = PokemonInfoState
    func newState(state: PokemonInfoState) {
        if state.selectedPokemon != nil {
            print("new state reload")
            pokemon = state.selectedPokemon
            reloadUI()
        }
    }
    
    var pokemonId: PokemonId!   // only name and id
    var pokemon: Pokemon!       // info
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self) { state in
            state.select { state in (state.pokemonInfoState) }
        }
        
        pokemonId = store.state.pokemonInfoState.selectedPokemonId
        pokemon = store.state.pokemonInfoState.selectedPokemon
        setupUI()
        //reloadUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    func setupUI() {
        barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        navBar.tintColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        view.addSubview(barView)
        
        navBar.topItem?.title = pokemonId.name
        spriteImageView.image = UIImage(contentsOfFile: spritePath.appendingPathComponent(String(pokemonId.id)).relativePath)
        
        if pokemon != nil {
            print("setup reload")
            loadingIndicator.isHidden = true
            reloadUI()
        } else {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        }
    }
    
    func reloadUI() {
        loadingIndicator.isHidden = true
        textView.text = pokemon?.text_entry ?? textView.text
        
        // Set colors
        let color = pokemon?.color ?? "default"
        barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = getUIColor(color)
        view.addSubview(barView)
        navBar.barTintColor = getUIColor(color)
        evoBarView.backgroundColor = getUIColor(color)
        
        // Set pokedex numbers
        kantoIndex.text = getIndex("kanto")
        johtoIndex.text = getIndex("original-johto")
        hoennIndex.text = getIndex("hoenn")
        sinnohIndex.text = getIndex("sinnoh")
        unovaIndex.text = getIndex("unova")
        kalosIndex.text = getIndex("kalos-central")
        
        heightValueLabel.text = String(describing: pokemon?.height).replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
        weightValueLabel.text = String(describing: pokemon?.weight).replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
    }
    
    func getIndex(_ region: String) -> String {
        if let index = pokemon?.indexes?[region] {
            return index
        } else {
            return "---"
        }
    }
    
    func getUIColor(_ color: String) -> UIColor {
        switch color {
        case "black":
            return UIColor(red:0.18, green:0.20, blue:0.21, alpha:1.0) //UIColor(red:0.78, green:0.78, blue:0.78, alpha:1.0)
        case "blue":
            return UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0) //UIColor(red:0.78, green:0.78, blue:0.98, alpha:1.0)
        case "brown":
            return UIColor(red:0.53, green:0.40, blue:0.40, alpha:1.0) //UIColor(red:0.92, green:0.85, blue:0.78, alpha:1.0)
        case "gray":
            return UIColor(red:0.50, green:0.55, blue:0.55, alpha:1.0) //UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        case "green":
            return UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0) //UIColor(red:0.78, green:0.98, blue:0.78, alpha:1.0)
        case "pink":
            return UIColor(red:0.99, green:0.47, blue:0.66, alpha:1.0) //UIColor(red:0.98, green:0.82, blue:0.98, alpha:1.0)
        case "purple":
            return UIColor(red:0.61, green:0.35, blue:0.71, alpha:1.0) //UIColor(red:0.93, green:0.78, blue:0.93, alpha:1.0)
        case "red":
            return UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0) //UIColor(red:0.98, green:0.78, blue:0.78, alpha:1.0)
        case "white":
            return UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.0) //UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        case "yellow":
            return UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.0) //UIColor(red:0.98, green:0.98, blue:0.78, alpha:1.0)
        default:
            return UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0) //UIColor(red:0.98, green:0.78, blue:0.78, alpha:1.0)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        store.dispatch(UpdatePokemonAction(selectedPokemon: nil))
        self.dismiss(animated: true, completion: nil)
    }
    
}
