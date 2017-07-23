//
//  LobbyViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/12/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {
    
    // MARK: *** Local variables
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    
    // MARK: *** UI Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "LobbyCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: LobbyCell.idXib)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCreateTrip(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "SetUpTrip", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"setupTripVC")
        present(viewController, animated: true)
    }
    @IBAction func onDevice(_ sender: UIButton) {
        print("Device")
        let deviceVC = DeviceViewController(nibName: "DeviceViewController", bundle: nil)
        present(deviceVC, animated: true, completion: nil)
    }
}
extension LobbyViewController : UITableViewDelegate, UITableViewDataSource{
    // MARK: *** UITableView
    //return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    //set data for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LobbyCell.idXib) as! LobbyCell
        return cell;
    }
}
