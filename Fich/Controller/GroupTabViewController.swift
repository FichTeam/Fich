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
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // alert control
        alertControlInit()
        // prepare data to display
        prepareData()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        if let refHandle = tripRefHandle {
            tripRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    // Section initialize
    // 0: Distance set      1
    // 1: Device info       1
    // 2: Fake Label        1
    // 3: Group             count
  
    let distanceSection = 0
    let deviceSection = 1
    let groupSection = 2
    let memberSection = 3
  
    var distanceList : [Int: String] = [2: "2km", 3: "3km", 5: "5km"]
    var distanceSet = 2
    var isBLEDeviceReady = true
    var isBTOn = false
  
  @IBOutlet weak var tripStatusLabel: UILabel!
  
  @IBAction func onTripStatusPressed(_ sender: UIButton) {
    if let trip = trip {
      if (trip.userId == Auth.auth().currentUser?.uid){
        switch trip.status! {
        case TripStatus.prepare:
          FirebaseClient.sharedInstance.startTrip(tripId: tripId)
          break
        case TripStatus.run:
          // finish
          FirebaseClient.sharedInstance.finishTrip(tripId: tripId)
          break
        case TripStatus.finish:
          // finish
          FirebaseClient.sharedInstance.finishTrip(tripId: tripId)
          dismiss(animated: true, completion: nil)
          break
        }
      } else {
        print("member")
      }
    } else {
      leaveTrip()
    }
}
  
  @IBAction func onLeavePressed(_ sender: UIButton) {
    leaveTrip()
    dismiss(animated: true, completion: nil)
  }
}

extension GroupTabViewController: UITableViewDelegate, UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        switch section {
        case self.distanceSection: return 1
        case self.deviceSection: return 1
        case self.groupSection: return 1
        case self.memberSection: return members.count
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      print("tableview load")
        switch indexPath.section {
        case self.distanceSection:
          print("section \(indexPath.section)")
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingCell
            cell.titleLabel.text = "Safe Distance"
            cell.statusLabel.text = distanceList[distanceSet]
            // TODO-PHAT: You should put this data "distanceSet" on Firebase to compute distance
            return cell
        case self.deviceSection:
          print("section \(indexPath.section)")
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingCell
            cell.titleLabel.text = "Device Info"
            if (self.isBLEDeviceReady){
                cell.statusLabel.text =  "Device is connected"
            }
            else{
              if (self.isBTOn == false){
                  cell.statusLabel.text =  "Turn on Bluetooth"
              }
              else{
                  cell.statusLabel.text =  "Click to add Device"
              }
            }
            return cell
        case self.groupSection:
          print("section \(indexPath.section)")
          let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupCell
          if let trip = trip {
            switch trip.status! {
            case TripStatus.prepare:
              self.tripStatusLabel.text = "PLANING..."
              break
            case TripStatus.run:
              self.tripStatusLabel.text = "RUNNING"
              break
            case TripStatus.finish:
              self.tripStatusLabel.text = "FINISH"
              break
            }
          }
          cell.selectionStyle = .none
          return cell
        case self.memberSection:
          print("section \(indexPath.section)")
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! MemberCell
            cell.account = members[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case self.distanceSection:
            self.present(alertController, animated: true, completion: nil)
          
        case self.deviceSection:
            // check status of device
            if (BleApi.sharedInstance.checkBTstate() != BluetoothState.poweredOn ){
                self.isBTOn = false
                self.isBLEDeviceReady = false
              self.tableView.reloadSections(IndexSet(integer: self.deviceSection), with: .automatic)
                break}
            
            self.isBTOn = true
            if (BleApi.sharedInstance.CheckAnyFichDeviceConnected() > 0)
            {
                print("Device ready")
                self.isBLEDeviceReady = true
                // show a message device is ready and reload this section
            }
            else
            {
                print("No device")
                self.isBLEDeviceReady = false
                // perform a segue to BLE page
                self.performSegue(withIdentifier: "BLESegueID", sender: self)
            }
            self.tableView.reloadSections(IndexSet(integer: self.deviceSection), with: .automatic)
        case self.groupSection: break
        case self.memberSection: break
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
//        dismiss(animated: true, completion: nil)
    }
    
    func alertControlInit(){
        alertController = UIAlertController(title: "Chose Safe Distance", message: "Always keep all members in this distance", preferredStyle: UIAlertControllerStyle.actionSheet)
        let _2kmAction = UIAlertAction(title: "Distance: 2km", style: UIAlertActionStyle.default) { (action)-> Void in
            // chose 2km
            print("chose 2km")
            self.distanceSet = 2
            self.tableView.reloadSections(IndexSet(integer: self.distanceSection), with: .automatic)
        }
        
        let _3kmAction = UIAlertAction(title: "Distance: 3km", style: UIAlertActionStyle.default) { (action)-> Void in
            // chose 2km
            print("chose 3km")
            self.distanceSet = 3
            self.tableView.reloadSections(IndexSet(integer: self.distanceSection), with: .automatic)
        }
        
        let _5kmAction = UIAlertAction(title: "Distance: 5km", style: UIAlertActionStyle.default) { (action)-> Void in
            // chose 2km
            print("chose 5km")
            self.distanceSet = 5
            self.tableView.reloadSections(IndexSet(integer: self.distanceSection), with: .automatic)
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
            self.isBTOn = true
            if (BleApi.sharedInstance.CheckAnyFichDeviceConnected() > 0){
                self.isBLEDeviceReady = true
            } else {
                self.isBLEDeviceReady = false
            }
        }
        else {
            self.isBTOn = false
            print("BT off")
        }
//        self.tripStatusLabel.text = "Planning..."
    }
  
  
}

