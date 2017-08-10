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
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var tripSearchResult: Trip?
    var userStatusRef: DatabaseReference?
    var userStatusRefHandle: DatabaseHandle?
    var bottomHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShowNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHideNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        joinButton.isHidden = true
        bottomHeight = bottomConstraint.constant
        addDoneButton(to: phoneNumberTextField)
        phoneNumberTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        self.showTrip(trip: nil)
        
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
        FirebaseClient.sharedInstance.joinTrip(tripId: (tripSearchResult?.id)!)
        phoneNumberTextField.text = ""
        editingChanged(phoneNumberTextField)
        joinButton.isHidden = true
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SetUpTrip", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"setupTripVC")
        present(viewController, animated: true)
        
        //        BleApi.sharedInstance.blink()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func keyboardShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            
            let delta = (keyboardSize?.height)! - (view.frame.size.height - (tripOwnerAvatarImage.frame.size.height + tripOwnerAvatarImage.frame.origin.y))
            bottomConstraint.constant = bottomHeight - (delta + 5)
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func keyboardHideNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            bottomConstraint.constant = bottomHeight
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}
