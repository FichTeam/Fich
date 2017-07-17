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
        //        let lobbyVC = LobbyViewController(nibName: "LobbyViewController", bundle: nil)
        
        //        present(lobbyVC, animated: true, completion: nil)
        
        let account = Account(dictionary: ["account_id": "26XnlUyXL6QQ3B7phPEF28jB5Qt2",
                                           "avatar": "https://scontent.xx.fbcdn.net/v/t1.0-1/p100x100/17309174_1451648118192501_7257638711077975293_n.jpg?oh=7d3a68823b8d6123a44a30e544a4dba6&oe=59E82413",
                                           "name": "Tran Tien Tin 123",
                                           "phone_number": "0902675405",
                                           "created_at": Double(1497787630826),
                                           "modified_at": Double(1497787630826)])
        FirebaseClient.sharedInstance.update(account: account)
    }
    
}

