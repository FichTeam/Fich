//
//  Account.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class Account: DataObject {
    var accountId: String?
    var name: String?
    var avatar: String?
    var phoneNumber: String?
    
    override init(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        accountId = dictionary["account_id"] as? String
        name = dictionary["name"] as? String
        avatar = dictionary["avatar"] as? String
        phoneNumber = dictionary["phone_number"] as? String
    }
    
    func toAccountDictionary() -> NSDictionary {
        var accountDictionary = [String: Any]()
        accountDictionary["account_id"] = accountId
        accountDictionary["name"] = name
        accountDictionary["avatar"] = avatar
        accountDictionary["phone_number"] = phoneNumber
        accountDictionary["created_at"] = (createdAt?.timeIntervalSince1970)! * 1000
        accountDictionary["modified_at"] = (modifiedAt?.timeIntervalSince1970)! * 1000
        return accountDictionary as NSDictionary
    }
}
