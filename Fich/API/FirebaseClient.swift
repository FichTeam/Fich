//
//  FirebaseClient.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class FirebaseClient {
    static let sharedInstance = FirebaseClient()
    var ref: DatabaseReference!
    
    private init() {
        ref = Database.database().reference()
    }
    
    func update() {
        let user = Auth.auth().currentUser
        if let user = user {
            let account = Account(user: user)
            let accountDictionary = account.toAccountDictionary()
            let childUpdates = ["account/\(account.accountId!)": accountDictionary]
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
        let childUpdates = ["/trip/\(trip.id!)": tripDictionary]
        ref.updateChildValues(childUpdates)
    }
    
    func lookupTrip(phoneNumber: String, completion: @escaping (Trip?, Error?) -> ()) {
        ref.child("trip_lobby").child(phoneNumber).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? [String: Any]
            
            if let value = value {
                let trip = Trip(dictionary: value)
                completion(trip, nil)
            } else {
                print ("nil")
                completion(nil, nil)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func joinTrip(tripId: String, completion: @escaping (Error?) -> ()) {
        let user = Auth.auth().currentUser
        if let user = user {
            let account = Account(user: user)
            let accountMap = account.toAccountDictionary()
            //accountMap["owner"] = false
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
                    completion(error)
            }
        } else {
            
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
    
}
