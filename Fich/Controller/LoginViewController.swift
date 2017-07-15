//
//  LoginViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/9/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(_ sender: UIButton) {
        let lobbyVC = LobbyViewController(nibName: "LobbyViewController", bundle: nil)
        
        present(lobbyVC, animated: true, completion: nil)
    }

}

