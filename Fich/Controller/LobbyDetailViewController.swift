//
//  LobbyDetailViewController.swift
//  Fich
//
//  Created by admin on 7/22/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class LobbyDetailViewController: UIViewController {

    @IBAction func onPairDevice(_ sender: UIBarButtonItem) {
        let deviceVC = TestViewController(nibName: "TestViewController", bundle: nil)
        present(deviceVC, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
