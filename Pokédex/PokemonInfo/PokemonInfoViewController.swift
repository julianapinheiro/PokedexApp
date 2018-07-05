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
    
    // Pokedex numbers
    @IBOutlet weak var kantoIndex: UILabel!
    @IBOutlet weak var johtoIndex: UILabel!
    @IBOutlet weak var hoennIndex: UILabel!
    @IBOutlet weak var sinnohIndex: UILabel!
    @IBOutlet weak var unovaIndex: UILabel!
    @IBOutlet weak var kalosIndex: UILabel!
    
    @IBOutlet weak var evoBarView: UIView!
    var barView: UIView!
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    typealias StoreSubscriberStateType = PokemonInfoState
    func newState(state: PokemonInfoState) {
        if state.selectedPokemon != nil {
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
        reloadUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    func setupUI() {
        barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor(red:0.98, green:0.78, blue:0.78, alpha:1.0)
        view.addSubview(barView)
        
        navBar.topItem?.title = pokemonId.name
        spriteImageView.image = UIImage(contentsOfFile: spritePath.appendingPathComponent(String(pokemonId.id)).relativePath)
        
        if pokemon != nil {
            reloadUI()
        }
    }
    
    func reloadUI() {
        textView.text = pokemon?.text_entry ?? textView.text
        
        let color = pokemon?.color ?? "default"
        barView.backgroundColor = colorUI(color: color)
        navBar.barTintColor = colorUI(color: color)
        evoBarView.backgroundColor = colorUI(color: color)
        
        kantoIndex.text = pokemon?.indexes?["kanto"]! ?? "---"
        johtoIndex.text = pokemon?.indexes?["original-johto"]! ?? "---"
        hoennIndex.text = pokemon?.indexes?["hoenn"]! ?? "---"
        sinnohIndex.text = pokemon?.indexes?["sinnoh"]! ?? "---"
        unovaIndex.text = pokemon?.indexes?["unova"]! ?? "---"
        kalosIndex.text = pokemon?.indexes?["kalos-central"]! ?? "---"
    }
    
    func colorUI(color: String) -> UIColor {
        switch color {
        case "black":
            return UIColor(red:0.78, green:0.78, blue:0.78, alpha:1.0)
        case "blue":
            return UIColor(red:0.78, green:0.78, blue:0.98, alpha:1.0)
        case "brown":
            return UIColor(red:0.92, green:0.85, blue:0.78, alpha:1.0)
        case "gray":
            return UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        case "green":
            return UIColor(red:0.78, green:0.98, blue:0.78, alpha:1.0)
        case "pink":
            return UIColor(red:0.98, green:0.82, blue:0.98, alpha:1.0)
        case "purple":
            return UIColor(red:0.93, green:0.78, blue:0.93, alpha:1.0)
        case "red":
            return UIColor(red:0.98, green:0.78, blue:0.78, alpha:1.0)
        case "white":
            return UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        case "yellow":
            return UIColor(red:0.98, green:0.98, blue:0.78, alpha:1.0)
        default:
            return UIColor(red:0.98, green:0.78, blue:0.78, alpha:1.0)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
