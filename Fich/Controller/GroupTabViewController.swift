//
//  GroupTabViewController.swift
//  Fich
//
//  Created by admin on 8/2/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase
import RxBluetoothKit
import RxSwift
import CoreBluetooth

class GroupTabViewController: UIViewController {
    
    var tripId: String! {
        didSet {
            tripRef = Database.database().reference().child("trip").child(tripId)
            observeTrip()
        }
    }
    
    var trip:Trip?
    
    @IBOutlet weak var tableView: UITableView!
    
    var members = [Account]()
    var tripRef: DatabaseReference?
    var tripRefHandle: DatabaseHandle?
    
    //Initialize UIAlertController for Safe Distance action sheet
    
    var alertController : UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // alert control
        alertControlInit()
        // prepare data to display
        prepareData()
        
    }
    
    deinit {
        if let refHandle = tripRefHandle {
            tripRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    // Section initialize
    // 0: Trip status       1
    // 1: Distance set      1
    // 2: Device info       1
    // 3: Group             count
    var distanceList : [Int: String] = [2: "2km", 3: "3km", 5: "5km"]
    var distanceSet = 2
    var isBLEDeviceReady = true
    
    
    
}

extension GroupTabViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        case 3: return members.count
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingCell
            // TODO-TIN : we will have trip-status on Firebase
            // you could pull this data then update for variable tripStatus
            
            if let trip = trip {
                cell.button.isHidden = false
                
                switch trip.status! {
                case TripStatus.prepare:
                    cell.statusLabel.text = "PREPARING"
                    cell.button.setTitle("START", for: .normal)
                    break
                case TripStatus.run:
                    cell.statusLabel.text = "RUNNING"
                    cell.button.setTitle("FINISH", for: .normal)
                    break
                case TripStatus.finish:
                    cell.statusLabel.text = "FINISH"
                    cell.button.setTitle("FINISH", for: .normal)
                    break
                }
                
                if (trip.userId != Auth.auth().currentUser?.uid){
                    cell.button.setTitle("LEAVE", for: .normal)
                }
                cell.delegate = self
            } else {
                cell.statusLabel.text = "Planning"
                cell.button.isHidden = false
                cell.button.setTitle("LEAVE", for: .normal)
                cell.delegate = self
            }
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingCell
            cell.statusLabel.text = distanceList[distanceSet]
            cell.button.isHidden = true
            // TODO-PHAT: You should put this data "distanceSet" on Firebase to compute distance
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingCell
            if (isBLEDeviceReady){
                cell.statusLabel.text =  "Device is connected"
            }
            else{
                cell.statusLabel.text =  "Click to add Device"
            }
            cell.button.isHidden = true
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! MemberCell
            cell.account = members[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        var headerTitle = UILabel()
        headerTitle = UILabel(frame: CGRect(x: 15, y: 15, width: 200, height: 35))
        switch section {
        case 0: headerTitle.text = "Trip Status"
        case 1: headerTitle.text = "Safe Distance"
        case 2: headerTitle.text = "Device"
        case 3: headerTitle.text = "Group"
        default: headerTitle.text = ""
        }
        headerTitle.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
        headerView.addSubview(headerTitle)
        headerView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1:
            self.present(alertController, animated: true, completion: nil)
        case 2:
            // check status of device
            if (BleApi.sharedInstance.checkBTstate() != BluetoothState.poweredOn ){
                break}
            
            if (BleApi.sharedInstance.CheckAnyFichDeviceConnected() > 0)
            {
                print("Device ready")
                isBLEDeviceReady = true
                // show a message device is ready and reload this section
            }
            else
            {
                print("No device")
                isBLEDeviceReady = false
                // perform a segue to BLE page
                self.performSegue(withIdentifier: "BLESegueID", sender: self)
            }
            self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        case 3: break
        default: break
        }
    }
}

extension GroupTabViewController {
    func observeTrip() {
        
        tripRefHandle = tripRef?.observe(.value, with: { (snapshot) in
            
            let tripDict = snapshot.value as? [String: Any]
            if let tripData = tripDict {
                self.trip = Trip(dictionary: tripData)
                self.members = [Account](self.trip!.members.values)
                if (self.tableView != nil){
                    self.tableView.reloadData()
                }
                if (self.trip?.status == TripStatus.finish) {
                    self.leaveTrip()
                }
            } else {
                print("error to decode trip. stop trip")
                self.members = [Account]()
            }
            
        })
    }
    
    func leaveTrip() {
        FirebaseClient.sharedInstance.leaveTrip(tripId: tripId)
        dismiss(animated: true, completion: nil)
    }
    
    func alertControlInit(){
        alertController = UIAlertController(title: "Chose Safe Distance", message: "Always keep all members in this distance", preferredStyle: UIAlertControllerStyle.actionSheet)
        let _2kmAction = UIAlertAction(title: "Distance: 2km", style: UIAlertActionStyle.default) { (action)-> Void in
            // chose 2km
            print("chose 2km")
            self.distanceSet = 2
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
        
        let _3kmAction = UIAlertAction(title: "Distance: 3km", style: UIAlertActionStyle.default) { (action)-> Void in
            // chose 2km
            print("chose 3km")
            self.distanceSet = 3
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
        
        let _5kmAction = UIAlertAction(title: "Distance: 5km", style: UIAlertActionStyle.default) { (action)-> Void in
            // chose 2km
            print("chose 5km")
            self.distanceSet = 5
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
        
        let _cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action)-> Void in
            // chose 2km
            print("Cancel")
        }
        alertController.addAction(_2kmAction)
        alertController.addAction(_3kmAction)
        alertController.addAction(_5kmAction)
        alertController.addAction(_cancelAction)
        
    }
    
    func prepareData(){
        // TODO-PHAT: You should update clone the distance data and update for "distanceSet"
        // currently I set this value is 2
        distanceSet = 2
        // check BLE device
        
        if(BleApi.sharedInstance.checkBTstate() == BluetoothState.poweredOn){
            print("BT on")
            if (BleApi.sharedInstance.CheckAnyFichDeviceConnected() > 0){
                isBLEDeviceReady = true
            } else {
                isBLEDeviceReady = false
            }
        }
        else {
            print("BT off")
        }
    }
    
}

extension GroupTabViewController: SettingButtonDelegate {
    func buttonPress(cell: SettingCell) {
        // trip action
        print("button press")
        if let trip = trip {
            if (trip.userId == Auth.auth().currentUser?.uid){
                switch trip.status! {
                case TripStatus.prepare:
                    // start
                    FirebaseClient.sharedInstance.startTrip(tripId: tripId)
                    break
                case TripStatus.run:
                    // finish
                    FirebaseClient.sharedInstance.finishTrip(tripId: tripId)
                    dismiss(animated: true, completion: nil)
                    break
                case TripStatus.finish:
                    // finish
                    FirebaseClient.sharedInstance.finishTrip(tripId: tripId)
                    dismiss(animated: true, completion: nil)
                    break
                }
                
            } else {
                leaveTrip()
            }
        } else {
            leaveTrip()
        }
    }
}

