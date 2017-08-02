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
            let storyboard = UIStoryboard(name: "GroupAndMap", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"groupAndMapViewController") as! GroupAndMapViewController
            viewController.tripId = self.trip?.id
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SetUpTrip", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"setupTripVC")
        present(viewController, animated: true)
    }
  @IBAction func onSetting(_ sender: UIButton) {
    let deviceVC = DeviceViewController(nibName: "DeviceViewController", bundle: nil)
    
    present(deviceVC, animated: true, completion: nil)

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
