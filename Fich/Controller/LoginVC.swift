//
//  LoginVC.swift
//  Fich
//
//  Created by admin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    // MARK: *** Local variables
    
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    
    // MARK: *** UI Events
    @IBAction func onSignup(_ sender: UIButton) {
        
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        let lobbyVC = LobbyViewController(nibName: "LobbyViewController", bundle: nil)
        present(lobbyVC, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        initButton()
        
    }
    
    func initButton(){
        btnPhone.layer.cornerRadius = btnPhone.frame.height/2
        btnPhone.clipsToBounds = true
        btnPhone.layer.shadowOffset = CGSize(width: -1, height: 1)
        btnPhone.layer.shadowOpacity = 0.2
        
        btnFacebook.layer.cornerRadius = btnPhone.frame.height/2
        btnFacebook.clipsToBounds = true
        btnFacebook.layer.shadowOffset = CGSize(width: -1, height: 1)
        btnFacebook.layer.shadowOpacity = 0.2
    }
}
