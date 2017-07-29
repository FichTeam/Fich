//
//  LobbyVC.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/28/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class LobbyVC: UIViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.isEnabled = false
        phoneNumberTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onJoin(_ sender: UIButton) {
        FirebaseClient.sharedInstance.join(trip: <#T##String#>)
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        
    }
    
    func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty
            else {
                self.joinButton.isEnabled = false
                return
        }
        joinButton.isEnabled = true
    }
    
}
