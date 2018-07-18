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
    @IBOutlet weak var nationalLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    // Pokedex numbers
    @IBOutlet weak var kantoIndex: UILabel!
    @IBOutlet weak var johtoIndex: UILabel!
    @IBOutlet weak var hoennIndex: UILabel!
    @IBOutlet weak var sinnohIndex: UILabel!
    @IBOutlet weak var unovaIndex: UILabel!
    @IBOutlet weak var kalosIndex: UILabel!
    @IBOutlet weak var nationalIndex: UILabel!
    
    @IBOutlet weak var heightValueLabel: UILabel!
    @IBOutlet weak var weightValueLabel: UILabel!
    @IBOutlet weak var typeValueLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var evoBarView: UIView!
    var barView: UIView!
    
    @IBOutlet weak var moreEvoStackView: UIStackView!
    @IBOutlet weak var firstFormImageView: UIImageView!
    @IBOutlet weak var secondFormImageView: UIImageView!
    @IBOutlet weak var thirdFormImageView: UIImageView!
    
    // -------------------------------------------------------------------------
    // MARK: - StoreSubscriber
    
    typealias StoreSubscriberStateType = PokemonInfoState
    func newState(state: PokemonInfoState) {
        if state.selectedPokemon != nil {
            pokemon = state.selectedPokemon
            reloadUI()
        }
        if state.selectedPokemonId != nil {
            pokemonId = state.selectedPokemonId!
        }
    }
    
    var pokemonId: PokemonId!   // only name and id
    var pokemon: Pokemon!       // info
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self) { state in
            state.select { state in (state.pokemonInfoState) }
        }
        
        setupUI()
        loadPokemon()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    func loadPokemon() {
        PokemonInfoService.shared.loadPokemon(Int(pokemonId.id), { success in
            if !success {
                self.loadingIndicator.isHidden = true
                let alert = UIAlertController(title: "Alert", message: "Failed to fetch Pokémon Info from API", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Set up UI functions
    
    func setupUI() {
        barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        navBar.barTintColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        view.addSubview(barView)
        
        navBar.topItem?.title = pokemonId.name
        spriteImageView.image = UIImage(contentsOfFile: PokedexListService.shared.spritePath.appendingPathComponent(String(pokemonId.id)).relativePath)
        
        if pokemon != nil {
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
        unovaIndex.text = getIndex("original-unova")
        kalosIndex.text = getIndex("kalos-central")
        nationalIndex.text = String(pokemon.id)
        
        for label in [kantoLabel, johtoLabel, hoennLabel, sinnohLabel, unovaLabel, kalosLabel, nationalLabel, heightLabel, weightLabel, typeLabel] {
            label?.textColor = getUIColor(color)
        }
        
        heightValueLabel.text = String(describing: pokemon!.height) + "m"
        weightValueLabel.text = String(describing: pokemon!.weight) + "kg"
        
        let types:String
        let type1:String = (pokemon?.types![0])!.capitalized
        if pokemon.types!.count > 1 {
            let type2:String = (pokemon?.types![1])!.capitalized
            types = type1 + "/" + type2
        } else {
            types = type1
        }
        typeValueLabel.text = types
        
        // evoluções was a mistake
        if pokemon.evolutionChain != nil {
            
            let formImageViews = [firstFormImageView, secondFormImageView, thirdFormImageView]
            var index = 0
            for formId in pokemon.evolutionChain! {
                PokedexListService.shared.fetchSprite(pokemonId: Int(formId)) { result in
                    formImageViews[index]?.image = UIImage(contentsOfFile: PokedexListService.shared.spritePath.appendingPathComponent(String(formId)).relativePath)
                }
                index += 1
                if index > 2 {
                    break
                }
            }
            
            if pokemon.evolutionChain!.count > 3 {
                var extraEvo = pokemon.evolutionChain!
                extraEvo.removeSubrange(0...2)
                let count = extraEvo.underestimatedCount
                var extraImages = Array(repeating: UIImageView(), count: count)
                
                for index in 0...count - 1 {
                    PokedexListService.shared.fetchSprite(pokemonId: Int(extraEvo[index])) { result in
                        extraImages[index] = UIImageView(image: UIImage(contentsOfFile: PokedexListService.shared.spritePath.appendingPathComponent(String(extraEvo[index])).relativePath))
                    }
                }
                
                for image in extraImages {
                    moreEvoStackView.addArrangedSubview(image)
                }
            }
        }
    }
 
    // -------------------------------------------------------------------------
    // MARK: - IBActions
    
    @IBAction func firstFormPressed(_ sender: Any) {
        if pokemon.evolutionChain?.count == 1 {
            return
        } else if pokemon.evolutionChain![0] == pokemon.id {
            return
        } else {
            let evo = store.state.pokedexListState.pokedexList.first(where: { $0.id == pokemon.evolutionChain![0]} )
            store.dispatch(SelectPokemonIdAction(pokemon: evo!))
            performSegue(withIdentifier: "showForm", sender: nil)
        }
    }
    
    @IBAction func secondFormPressed(_ sender: Any) {
        if pokemon.evolutionChain?.count == 1 {
            return
        } else if pokemon.evolutionChain![1] == pokemon.id {
            return
        } else {
            let evo = store.state.pokedexListState.pokedexList.first(where: { $0.id == pokemon.evolutionChain![1]} )
            store.dispatch(SelectPokemonIdAction(pokemon: evo!))
            performSegue(withIdentifier: "showForm", sender: nil)
        }
    }
    
    @IBAction func thirdFormPressed(_ sender: Any) {
        if pokemon.evolutionChain?.count == 1 {
            return
        } else if pokemon.evolutionChain![2] == pokemon.id {
            return
        } else {
            let evo = store.state.pokedexListState.pokedexList.first(where: { $0.id == pokemon.evolutionChain![2]} )
            store.dispatch(SelectPokemonIdAction(pokemon: evo!))
            performSegue(withIdentifier: "showForm", sender: nil)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        store.dispatch(UpdatePokemonAction(pokemon: nil))
        self.dismiss(animated: true, completion: nil)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Helper functions
    
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
            return UIColor(red:0.18, green:0.20, blue:0.21, alpha:1.0)
        case "blue":
            return UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
        case "brown":
            return UIColor(red:0.53, green:0.40, blue:0.40, alpha:1.0)
        case "gray":
            return UIColor(red:0.50, green:0.55, blue:0.55, alpha:1.0)
        case "green":
            return UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
        case "pink":
            return UIColor(red:0.99, green:0.47, blue:0.66, alpha:1.0)
        case "purple":
            return UIColor(red:0.61, green:0.35, blue:0.71, alpha:1.0)
        case "red":
            return UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        case "white":
            return UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.0)
        case "yellow":
            return UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.0)
        default:
            return UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        }
    }

    
    
}
