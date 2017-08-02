//
//  Account.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase

class Account: DataObject {
    var accountId: String?
    var name: String?
    var avatar: String?
    var phoneNumber: String?
    
    override init(dictionary: [String: Any]) {
        super.init(dictionary: dictionary)
        accountId = dictionary["account_id"] as? String
        name = dictionary["name"] as? String
        avatar = dictionary["avatar"] as? String
        phoneNumber = dictionary["phone_number"] as? String
    }
    
    func toAccountDictionary() -> [String: Any] {
        var accountDictionary = [String: Any]()
        accountDictionary["account_id"] = accountId
        accountDictionary["name"] = name
        accountDictionary["avatar"] = avatar
        accountDictionary["phone_number"] = phoneNumber
        accountDictionary["created_at"] = (createdAt?.timeIntervalSince1970)! * 1000
        accountDictionary["modified_at"] = (modifiedAt?.timeIntervalSince1970)! * 1000
        return accountDictionary
    }
    
    init(user: User) {
        super.init()
        accountId = user.uid
        name = user.displayName
        avatar = user.photoURL?.absoluteString
        phoneNumber = user.phoneNumber
    }
}
