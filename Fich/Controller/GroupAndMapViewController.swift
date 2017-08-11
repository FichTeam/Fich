//
//  GroupAndMapViewController.swift
//  Fich
//
//  Created by admin on 8/2/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox

class GroupAndMapViewController: UIViewController {
    
    var tripId: String! {
        didSet {
            tripRef = Database.database().reference().child("trip").child(tripId)
            observeTrip()
            messageRef = Database.database().reference().child("trip_action").child(tripId)
            self.observeNewMessages()
        }
    }
    var messageRef: DatabaseReference?
    var messageRefHandle: DatabaseHandle?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonBackgrounds: [UIView]!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuBacground: UIView!
    
    var mapViewController: MapTabViewController!
    var groupViewController: GroupTabViewController!
    
    var viewControllers: [UIViewController]!
    
    var selectedIndex: Int = 1
    var tripRef: DatabaseReference?
    var tripRefHandle: DatabaseHandle?
    var currentAccount: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "GroupAndMap", bundle: nil)
        mapViewController = storyboard.instantiateViewController(withIdentifier: "mapViewController") as! MapTabViewController
        groupViewController = storyboard.instantiateViewController(withIdentifier: "groupViewController") as! GroupTabViewController
        mapViewController.tripId = tripId
        groupViewController.tripId = tripId
        groupViewController.groupDelegate = mapViewController
        
        viewControllers = [mapViewController, groupViewController]
        
        didPressTab(buttons[0])
        menuBacground.isHidden = true
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.dismissMenu (_:)))
        menuBacground.addGestureRecognizer(gesture)
        
        
        //
        let user = Auth.auth().currentUser
        if let user = user {
            currentAccount = Account(user: user)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func dismissMenu(_ sender:UITapGestureRecognizer){
        print("didDismissPress")
        menuBacground.isHidden = true
    }
    
    @IBAction func didPressTab(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        
        buttonBackgrounds[previousIndex].backgroundColor = UIColor.lightGray
        buttons[previousIndex].setTitleColor(UIColor.darkText, for: .normal)
        buttons[previousIndex].titleLabel!.font = UIFont.boldSystemFont(ofSize: 16)
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        buttonBackgrounds[selectedIndex].backgroundColor = UIColor.init(rgb: 0xD8524F)
        buttons[selectedIndex].setTitleColor(UIColor.white, for: .normal)
        buttons[selectedIndex].titleLabel!.font = UIFont.boldSystemFont(ofSize: 20)
        let vc = viewControllers[selectedIndex]
        addChildViewController(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    @IBAction func didPressAction(_ sender: UIButton) {
        print("didPressAction")
        menuBacground.isHidden = false
    }
    
    @IBAction func didLostPress(_ sender: UIButton) {
        print("didLostPress")
        self.sendInstantMessage(action: ActionType.lost)
        menuBacground.isHidden = true
    }
    
    @IBAction func didBikeBrokenPress(_ sender: UIButton) {
        print("didBikeBrokenPress")
        self.sendInstantMessage(action: ActionType.bikeBroken)
        menuBacground.isHidden = true
    }
    
    @IBAction func didMessagePress(_ sender: UIButton) {
        print("didMessagePress")
        menuBacground.isHidden = true
        self.performSegue(withIdentifier: "ChatSegueID", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ActionViewController
        vc.tripId = tripId
    }
    
    deinit {
        if let refHandle = tripRefHandle {
            tripRef?.removeObserver(withHandle: refHandle)
        }
        if let refHandle = messageRefHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
    }
}

extension GroupAndMapViewController {
    func sendInstantMessage(action: ActionType)
    {
        let message = TripAction(member: currentAccount!, type: action, message: nil, messageUrl: nil)
        FirebaseClient.sharedInstance().sendAction(tripId: tripId, action: message, completion: { (error: Error?) in
            if let error = error {
                print (error)
            } else {
                self.performSegue(withIdentifier: "ChatSegueID", sender: self)
            }
        })
        
    }
    
    func observeNewMessages() {
        
        messageRefHandle = messageRef?.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            
            let messageDict = snapshot.value as? [String: Any]
            
            if let msgData = messageDict {
                let action = TripAction(dictionary: msgData)
                if action.type != ActionType.text {
                    print("notify notify")
                    AudioServicesPlayAlertSound(SystemSoundID(1015))
                    AudioServicesPlayAlertSound(SystemSoundID(1016))
                    BleApi.sharedInstance.blink()
                }
            } else {
                print("Error! Could not decode message data")
            }
            
        })
    }
    
    
    func observeTrip() {
        
        tripRefHandle = tripRef?.observe(.value, with: { (snapshot) in
            
            let tripDict = snapshot.value as? [String: Any]
            if let tripData = tripDict {
                //                let trip = Trip(dictionary: tripData)
                
            } else {
                print("error to decode trip. stop trip")
            }
            
        })
    }
}

