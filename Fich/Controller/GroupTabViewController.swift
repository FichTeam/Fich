//
//  GroupTabViewController.swift
//  Fich
//
//  Created by admin on 8/2/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase

class GroupTabViewController: UIViewController {
    
    var tripId: String! {
        didSet {
            tripRef = Database.database().reference().child("trip").child(tripId)
            observeTrip()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func onBack(_ sender: UIButton) {
        FirebaseClient.sharedInstance.leaveTrip(tripId: tripId)
        dismiss(animated: true, completion: nil)
    }
    
    var members = [Account]()
    var tripRef: DatabaseReference?
    var tripRefHandle: DatabaseHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    deinit {
        if let refHandle = tripRefHandle {
            tripRef?.removeObserver(withHandle: refHandle)
        }
    }
    
}

extension GroupTabViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! MemberCell

        cell.account = members[indexPath.row]

        return cell
    }
}

extension GroupTabViewController {
    func observeTrip() {
        
        tripRefHandle = tripRef?.observe(.value, with: { (snapshot) in
            
            let tripDict = snapshot.value as? [String: Any]
            if let tripData = tripDict {
                let trip = Trip(dictionary: tripData)
                self.members = [Account](trip.members.values)
            } else {
                print("error to decode trip. stop trip")
                self.members = [Account]()
            }
            
        })
    }
    
}

