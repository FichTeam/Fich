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
import Firebase

class FirebaseClient {
    static let sharedInstance = FirebaseClient()
    var ref: DatabaseReference!
    let storageRef = Storage.storage().reference()
    var uid = Auth.auth().currentUser?.uid
    
    private init() {
        ref = Database.database().reference()
    }
    
    func update() {
        let user = Auth.auth().currentUser
        if let user = user {
            let account = Account(user: user)
            let accountDictionary = account.toAccountDictionary()
            let childUpdates = ["user/\(uid!)": accountDictionary]
            ref.updateChildValues(childUpdates) { (error: Error?, data: DatabaseReference) in
                if let error = error {
                    print (error)
                } else {
                }
            }
        }
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
        UserDefaults.standard.set(key, forKey: "tripId")
        let childUpdates = ["/trip/\(key)": dict]
        ref.updateChildValues(childUpdates)
        
        let tripId : NSDictionary = ["trip_id": key]
        let update = ["/user/\(uid!)/trip/" : tripId]
        ref.updateChildValues(update)
        
        let id : NSDictionary = ["id": key]
        if let phonenumber = UserDefaults.standard.string(forKey: "phonenumber"){
            let tripLobby = ["/trip_lobby/\(phonenumber)" : id]
            ref.updateChildValues(tripLobby)
        }
        if Auth.auth().currentUser?.phoneNumber == nil{
            let code = UserDefaults.standard.string(forKey: "trip_code")
            if let code = code {
                let tripLobby = ["/trip_lobby/\(code)" : id]
                ref.updateChildValues(tripLobby)
            }
        }
        FirebaseClient.sharedInstance.joinTrip(tripId: key)
    }
    func lookupTrip(phoneNumber: String, completion: @escaping (Trip?, Error?) -> ()) {
        ref.child("trip_lobby").child(phoneNumber).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? [String: Any]
            
            if let value = value {
                let tripId = value["id"] as? String ?? ""
                self.ref.child("trip").child(tripId).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value2 = snapshot.value as? [String: Any]
                    let trip = Trip(dictionary: value2!)
                    trip.id = tripId
                    completion(trip, nil)
                })
            } else {
                print ("nil")
                completion(nil, nil)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func memberGetRoutine(tripId : String)->String{
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                var tripID = ""
                ref.child("trip").child(tripId).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print(snapshot)
                    let value = snapshot.value as? NSDictionary
                    print(value)
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                print("After snapshot \(tripID)")
                return tripID
            }
            return "nil"
        } else {
            return "nil"
        }
    }
    
    func addStopToDatabase(dict: NSDictionary){
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                var tripID = ""
                ref.child("user").child(uid).child("trip").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print(snapshot)
                    let value = snapshot.value as? NSDictionary
                    tripID = value?["trip_id"] as? String ?? ""
                    if tripID != ""{
                        //let key = self.ref.child("trip/\(tripID)/stops").childByAutoId().key
                        let childUpdates = ["/trip/\(tripID)/stops": dict]
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
                ref.child("user").child(uid).child("trip").observeSingleEvent(of: .value, with: { (snapshot) in
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
                ref.child("user").child(uid).child("trip").observeSingleEvent(of: .value, with: { (snapshot) in
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
                ref.child("user").child(uid).child("trip").observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    func memberUpdatePosition(tripid: String, cllocation : CLLocation){
        let pos = Position(loc: cllocation)
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                ref.child("trip").child(tripid).child("members").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print(snapshot)
                    //let value = snapshot.value as? NSDictionary
                    let childUpdates = ["/trip/\(tripid)/members/\(uid)/current_position": pos.toPositionDictionary()]
                    self.ref.updateChildValues(childUpdates)
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getAllMemberPosition(tripid: String, success: @escaping ([Position]) -> ()){
        var arrPos = [Position]()
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                ref.child("trip").child(tripid).child("members").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    //print(snapshot)
                    let arrayMember = snapshot.children.allObjects as? [DataSnapshot] ?? []
                    arrPos.removeAll()
                    for member in arrayMember{
                        if member.key != self.uid{
                            let dict = member.value as? [String: Any]
                            let pos = dict!["current_position"] as?  [String: Any]
                            if let pos = pos{
                                let p = Position(dictionary: pos)
                                p.name = dict!["name"] as? String
                                p.address = dict!["avatar"] as? String
                                arrPos.append(p)
                            }
                        }
                    }
                    success(arrPos)
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getAllPosition(tripid: String, success: @escaping ([Position]) -> ()){
        var arrPos = [Position]()
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                ref.child("trip").child(tripid).child("members").observeSingleEvent(of: .value, with: { (snapshot) in
                    let arrayMember = snapshot.children.allObjects as? [DataSnapshot] ?? []
                    arrPos.removeAll()
                    for member in arrayMember{
                        let dict = member.value as? [String: Any]
                        let pos = dict!["current_position"] as?  [String: Any]
                        if let pos = pos{
                            let p = Position(dictionary: pos)
                            arrPos.append(p)
                        }
                    }
                    success(arrPos)
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func joinTrip(tripId: String) {
        let user = Auth.auth().currentUser
        if let user = user {
            let account = Account(user: user)
            let accountMap = account.toAccountDictionary()
            
            // add member to trip
            ref.child("trip")
                .child(tripId)
                .child("members")
                .child(account.accountId!)
                .updateChildValues(accountMap) { (error: Error?, data: DatabaseReference) in
                    if (error != nil) {
                        print(error)
                    } else{
                        print(data)
                    }
            }
            // update user status
            let userTripValue = ["trip_id": tripId]
            ref.child("user")
                .child(user.uid)
                .child("trip")
                .updateChildValues(userTripValue) { (error: Error?, data: DatabaseReference) in
                    if (error != nil) {
                        print(error)
                    } else{
                        print(data)
                    }
            }
            
        }
    }
    
    func leaveTrip(tripId: String) {
        let user = Auth.auth().currentUser
        if let user = user {
            let account = Account(user: user)
            
            // remove member to trip
            ref.child("trip")
                .child(tripId)
                .child("members")
                .child(account.accountId!)
                .removeValue()
            
            // update user status
            ref.child("user")
                .child(user.uid)
                .child("trip")
                .removeValue()
            
        }
    }
    
    func startTrip(tripId: String) {
            // change trip status
            ref.child("trip")
                .child(tripId)
                .child("status").setValue(TripStatus.run.rawValue)
        
        if let phonenumber = UserDefaults.standard.string(forKey: "phonenumber"){
            ref.child("trip_lobby").child(phonenumber).removeValue()
        }
        if Auth.auth().currentUser?.phoneNumber == nil{
            let code = UserDefaults.standard.string(forKey: "trip_code")
            if let code = code {
                ref.child("trip_lobby").child(code).removeValue()
            }
        }
    }
    
    func finishTrip(tripId: String) {
        let user = Auth.auth().currentUser
        if let user = user {
                    
            // change trip status
            ref.child("trip")
                .child(tripId)
                .child("status").setValue(TripStatus.finish.rawValue)
            
            // update user status
            ref.child("user")
                .child(user.uid)
                .child("trip")
                .removeValue()
            
        }
    }
    
    func sendAction(tripId: String, action: TripAction, completion: @escaping (Error?) -> ()) {
        let actionRef = ref.child("trip_action").child(tripId)
        let newActionRef = actionRef.childByAutoId()
        let actionData = action.toActionDictionary()
        newActionRef.setValue(actionData, withCompletionBlock: { (error: Error?, data: DatabaseReference) in
            completion(error)
        })
    }
    
    func loadFakeData(success: @escaping ([Position]) -> ()){
        var arrPos = [Position]()
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                ref.child("fake_location").child("mid_points").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    //print(snapshot)
                    let arrayMidpoints = snapshot.children.allObjects as? [DataSnapshot] ?? []
                    arrPos.removeAll()
                    for mid in arrayMidpoints{
                        let pos = mid.value as? [String: Any]
                        if let pos = pos{
                            let p = Position(dictionary: pos)
                            arrPos.append(p)
                        }
                    }
                    success(arrPos)
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getStopUser(success: @escaping (String) -> ()){
        var stopId = ""
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                ref.child("fake_location").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    //print(snapshot)
                    let value = snapshot.value as? NSDictionary
                    stopId = value?["stop_id"] as? String ?? ""
                    success(stopId)
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    func isFakeData(success: @escaping (Bool) -> ()){
        var isFakeData = false
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                ref.child("fake_location").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    //print(snapshot)
                    let value = snapshot.value as? NSDictionary
                    isFakeData = value?["is_on"] as? Bool ?? false
                    success(isFakeData)
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
}
