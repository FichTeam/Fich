//
//  WaypointsViewController.swift
//  Fich
//
//  Created by admin on 7/23/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import CoreLocation

class WaypointsViewController: UIViewController {
    // MARK: *** Local variables
    var depPlace : String!
    var desPlace: String!
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    
    @IBOutlet weak var yourDeparture: UILabel!
    @IBOutlet weak var yourDestination: UILabel!
    // MARK: *** UI Events
    
    @IBAction func onBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        yourDeparture.text = depPlace
        yourDestination.text = desPlace
    }
    
}
