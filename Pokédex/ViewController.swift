//
//  ViewController.swift
//  Pokédex
//
//  Created by Juliana on 27/06/18.
//  Copyright © 2018 Bridge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var dataController:DataController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Loaded main")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let storyboard = UIStoryboard(name: "PokedexList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "PokedexListViewController") as! PokedexListViewController
        mainViewController.dataController = dataController
        present(mainViewController, animated: true,
                completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

