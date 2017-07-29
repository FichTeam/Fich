//
//  FirebaseClient.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
        let childUpdates = ["/trip/\(trip.id!)": tripDictionary]
        ref.updateChildValues(childUpdates)
    }
    
    func join(trip phoneNumber: String) {
        ref.child("trip_lobby").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let user = User.init(username: username)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
