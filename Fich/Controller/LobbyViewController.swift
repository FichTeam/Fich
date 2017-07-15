//
//  LobbyViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/12/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPairDevice(_ sender: UIButton) {
        let deviceVC = DeviceViewController(nibName: "DeviceViewController", bundle: nil)
        
        present(deviceVC, animated: true, completion: nil)
    }
}
