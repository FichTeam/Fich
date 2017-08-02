//
//  JoinLobbyViewController.swift
//  Fich
//
//  Created by admin on 8/2/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import AFNetworking

class JoinLobbyViewController: UIViewController {
    
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripOwnerAvatarImage: UIImageView!
    @IBOutlet weak var tripOwnerNameLabel: UILabel!
    
    var trip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.isEnabled = false
        phoneNumberTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        self.showTrip(trip: nil)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onJoin(_ sender: UIButton) {
        FirebaseClient.sharedInstance.joinTrip(tripId: (trip?.id)!) { (error: Error?) in
            //
        }
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SetUpTrip", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"setupTripVC")
        present(viewController, animated: true)
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
            tripNameLabel.text = trip.name
            tripOwnerAvatarImage.setImageWith(URL(string: (trip.owner?.avatar)!)!)
            tripOwnerNameLabel.text = trip.owner?.name
            
            tripNameLabel.isHidden = false
            tripOwnerAvatarImage.isHidden = false
            tripOwnerNameLabel.isHidden = false
            
            self.trip = trip
            joinButton.isEnabled = true
        } else {
            tripNameLabel.isHidden = true
            tripOwnerAvatarImage.isHidden = true
            tripOwnerNameLabel.isHidden = true
            
            self.trip = nil
            self.joinButton.isEnabled = false
        }
    }
    
}