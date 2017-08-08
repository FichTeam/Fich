//
//  JoinLobbyViewController.swift
//  Fich
//
//  Created by admin on 8/2/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import AFNetworking
import Firebase

class JoinLobbyViewController: UIViewController {
    
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripOwnerAvatarImage: UIImageView!
    @IBOutlet weak var tripOwnerNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var tripSearchResult: Trip?
    var userStatusRef: DatabaseReference?
    var userStatusRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.isHidden = true
        
        addDoneButton(to: phoneNumberTextField)
        phoneNumberTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        self.showTrip(trip: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        observeUserStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let refHandle = userStatusRefHandle {
            userStatusRef?.removeObserver(withHandle: refHandle)
        }
        
    }
    
    @IBAction func onJoin(_ sender: UIButton) {
        phoneNumberTextField.text = ""
        FirebaseClient.sharedInstance.joinTrip(tripId: (tripSearchResult?.id)!)
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SetUpTrip", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"setupTripVC")
        present(viewController, animated: true)
        
        //        BleApi.sharedInstance.blink()
    }
    
    @IBAction func onSetting(_ sender: UIButton) {
        //    let deviceVC = DeviceViewController(nibName: "DeviceViewController", bundle: nil)
        //
        //    present(deviceVC, animated: true, completion: nil)
        performSegue(withIdentifier: "deviceSettingSegue", sender: self)
    }
    
    func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty
            else {
                return
        }
        FirebaseClient.sharedInstance.lookupTrip(phoneNumber: phoneNumberTextField.text!) { (trip: Trip?, error: Error?) in
            self.showTrip(trip: trip)
        }
    }
    
    func showTrip(trip: Trip?) {
        if let trip = trip {
            tripNameLabel.text = trip.name ?? "\(trip.source!.name!) - \(trip.destination!.name!)"
            if let ava = trip.owner?.avatar{
                tripOwnerAvatarImage.setImageWith(URL(string: ava)!)
            }
            
            if trip.owner?.avatar == nil{
                tripOwnerAvatarImage.setImageWith(URL(string: "https://scontent.xx.fbcdn.net/v/t1.0-1/p100x100/15181674_1149858831776751_8014201392164943168_n.jpg?oh=74858256142603c91ce7f894848a9a77&oe=59FA5213")!)
            }
            tripOwnerNameLabel.text = trip.owner?.name ?? "Best trip ever!"
            
            tripNameLabel.isHidden = false
            tripOwnerAvatarImage.isHidden = false
            tripOwnerNameLabel.isHidden = false
            joinButton.isHidden = false
            
            self.tripSearchResult = trip
        } else {
            tripNameLabel.isHidden = true
            tripOwnerAvatarImage.isHidden = true
            tripOwnerNameLabel.isHidden = true
            self.joinButton.isHidden = true
            self.tripSearchResult = nil
        }
    }
    
}

extension JoinLobbyViewController {
    func observeUserStatus() {
        let user = Auth.auth().currentUser
        userStatusRef = Database.database().reference().child("user").child((user?.uid)!)
        userStatusRefHandle = userStatusRef?.observe(.value, with: { (snapshot) in
            
            let userDict = snapshot.value as? [String: Any]
            if let userDict = userDict {
                let trip = userDict["trip"] as? [String: Any]
                    if let trip = trip {
                        if let tripId = trip["trip_id"] as? String {
                            let storyboard = UIStoryboard(name: "GroupAndMap", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier :"groupAndMapViewController") as! GroupAndMapViewController
                            viewController.tripId = tripId
                            self.present(viewController, animated: true, completion: nil)
                        }
                    }
                
            } else {
                // not in a trip
            }
            
        })
    }
}
