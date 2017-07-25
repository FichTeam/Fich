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
    var steps: [Step] = []
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    @IBOutlet weak var tableView: UITableView!
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
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
}
extension WaypointsViewController : UITableViewDelegate, UITableViewDataSource{
    // MARK: *** UITableView
    //return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    //set data for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCellID") as! StepCell
        //cell.step = GoogleMapManager.shared.steps[0]
        return cell
    }
}
