//
//  MapViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/31/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func onChat(_ sender: UIButton) {
        performSegue(withIdentifier: "chatSegue", sender: self)
    }

}
