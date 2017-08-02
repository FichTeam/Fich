//
//  MainViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 8/1/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    var tripId: String! {
        didSet {
            tripRef = Database.database().reference().child("trip").child(tripId)
            observeTrip()
        }
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var buttonBackgrounds: [UIView]!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuBacground: UIView!
    
    var mapViewController: MapViewController!
    var groupViewController: GroupViewController!
    var viewControllers: [UIViewController]!
    
    var selectedIndex: Int = 0
    var tripRef: DatabaseReference?
    var tripRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        mapViewController = storyboard.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
        groupViewController = storyboard.instantiateViewController(withIdentifier: "groupViewController") as! GroupViewController
        mapViewController.tripId = tripId
        groupViewController.tripId = tripId
        
        viewControllers = [mapViewController, groupViewController]
        
        buttonBackgrounds[selectedIndex].backgroundColor = UIColor.darkGray
        didPressTab(buttons[selectedIndex])
        menuBacground.isHidden = true
    }

    @IBAction func didPressTab(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        
        buttonBackgrounds[previousIndex].backgroundColor = UIColor.lightGray
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        buttonBackgrounds[selectedIndex].backgroundColor = UIColor.darkGray
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
        menuBacground.isHidden = true
    }
    
    @IBAction func didBikeBrokenPress(_ sender: UIButton) {
        print("didBikeBrokenPress")
        menuBacground.isHidden = true
    }
    
    @IBAction func didMessagePress(_ sender: UIButton) {
        print("didMessagePress")
        menuBacground.isHidden = true
    }
    
    @IBAction func didDismissPress(_ sender: UIButton) {
        print("didDismissPress")
        menuBacground.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let vc = navController.viewControllers.first as! ChatViewController
        vc.tripId = tripId
    }
    
    deinit {
        if let refHandle = tripRefHandle {
            tripRef?.removeObserver(withHandle: refHandle)
        }
    }
}

extension MainViewController {
    func observeTrip() {
        
        tripRefHandle = tripRef?.observe(.value, with: { (snapshot) in
            
            let tripDict = snapshot.value as? [String: Any]
            if let tripData = tripDict {
                let trip = Trip(dictionary: tripData)
                
            } else {
                print("error to decode trip. stop trip")
            }
            
        })
    }
    
}
