//
//  FirebaseClient.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

class FirebaseClient {
    static let sharedInstance = FirebaseClient()
    var ref: DatabaseReference!
    var uid = Auth.auth().currentUser?.uid
    
    private init() {
        ref = Database.database().reference()
    }
    
    func update(account: Account) {
        let accountDictionary = account.toAccountDictionary()
        let childUpdates = ["account/\(account.accountId!)": accountDictionary]
        ref.updateChildValues(childUpdates)
    }
    
    func get(account id: String) {
        
    }
    
    func create(trip: Trip) {
        let tripDictionary = trip.toTripDictionary()
        let key = ref.child("trip").childByAutoId().key
        let childUpdates = ["/trip/\(key)": tripDictionary]
        ref.updateChildValues(childUpdates)
    }
    
    func createTripWithDict(dict: NSDictionary) {
        let key = ref.child("trip").childByAutoId().key
        let childUpdates = ["/trip/\(key)": dict]
        ref.updateChildValues(childUpdates)
        
        let tripId : NSDictionary = ["trip_id": key]
        let update = ["/user/\(uid!)" : tripId]
        ref.updateChildValues(update)
    }
    
    func addStopToDatabase(dict: NSDictionary){
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                var tripID = ""
                ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print(snapshot)
                    let value = snapshot.value as? NSDictionary
                    tripID = value?["trip_id"] as? String ?? ""
                    if tripID != ""{
                        let key = self.ref.child("trip/\(tripID)/stops").childByAutoId().key
                        let childUpdates = ["/trip/\(tripID)/stops/\(key)": dict]
                        self.ref.updateChildValues(childUpdates)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func removeStopFromDatabase(dict: NSDictionary){
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                var tripID = ""
                ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print(snapshot)
                    let value = snapshot.value as? NSDictionary
                    tripID = value?["trip_id"] as? String ?? ""
                    if tripID != ""{
                        self.ref.child("/trip/\(tripID)/stops").removeValue()
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getUserUID()->String?{
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                print(uid)
                return uid
            }
            return nil
        } else {
            return nil
        }
    }
    
    func getTripID()-> String?{
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                var tripID = ""
                ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print(snapshot)
                    let value = snapshot.value as? NSDictionary
                    tripID = value?["trip_id"] as? String ?? ""
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                print("After snapshot \(tripID)")
                return tripID
            }
            return nil
        } else {
            return nil
        }
    }
    
    func updatePosition(cllocation : CLLocation){
        let pos = Position(loc: cllocation)
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                var tripID = ""
                ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print(snapshot)
                    let value = snapshot.value as? NSDictionary
                    tripID = value?["trip_id"] as? String ?? ""
                    if tripID != ""{
                        //let key = self.ref.child("trip/\(tripID)/members/\(uid)/current_position").childByAutoId().key
                        let childUpdates = ["/trip/\(tripID)/members/\(uid)/current_position": pos.toPositionDictionary()]
                        self.ref.updateChildValues(childUpdates)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
}
