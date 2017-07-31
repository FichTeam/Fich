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

class FirebaseClient {
    static let sharedInstance = FirebaseClient()
    var ref: DatabaseReference!
    
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
}
