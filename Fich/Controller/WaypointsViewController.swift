//
//  WaypointsViewController.swift
//  Fich
//
//  Created by admin on 7/23/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import CoreLocation

protocol DismissDelegate {
    func setDismiss()
}

class WaypointsViewController: UIViewController {
    // MARK: *** Local variables
    
    var dismissDelegate: DismissDelegate!
    var isDone = false
    var depPlace : String!
    var desPlace: String!
    var steps: [Step] = []
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var yourDeparture: UILabel!
    @IBOutlet weak var yourDestination: UILabel!
    @IBOutlet weak var groupButton: UIButton!
    // MARK: *** UI Events
    
    @IBAction func onBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onGroup(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GroupAndMap", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"groupAndMapViewController") as! GroupAndMapViewController
        viewController.tripId = UserDefaults.standard.string(forKey: "tripId")
        isDone = true
        present(viewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        yourDeparture.text = depPlace
        yourDestination.text = desPlace
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (isDone) {
            self.dismissDelegate.setDismiss()
            dismiss(animated: false, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
extension WaypointsViewController : UITableViewDelegate, UITableViewDataSource{
    // MARK: *** UITableView
    //return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GoogleMapManager.shared.steps.count
    }
    //set data for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCellID") as! StepCell
        cell.step = GoogleMapManager.shared.steps[indexPath.row]
        return cell
    }
}
