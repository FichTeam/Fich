//
//  TripAction.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/31/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum ActionType: String {
    case lost = "LOST", bikeBroken = "BIKE_BROKEN", text = "TEXT", buzz = "BUZZ"
}


class TripAction: DataObject {
    var member: Account?
    var type: ActionType?
    var message: String?
    var messageUrl: String?
    
    override init(dictionary: [String: Any]) {
        super.init(dictionary: dictionary)
        let memberData = dictionary["member"] as? [String: Any]
        if let memberData = memberData {
            member = Account(dictionary: memberData)
        }
        
        let typeString = dictionary["type"] as? String
        if let typeString = typeString {
            type = ActionType.init(rawValue: typeString)
        }
        message = dictionary["message"] as? String
        messageUrl = dictionary["message_url"] as? String
    }
    
    func toActionDictionary() -> [String: Any] {
        var actionDictionary = [String: Any]()
        actionDictionary["member"] = member?.toAccountDictionary()
        actionDictionary["type"] = type?.rawValue
        actionDictionary["message"] = message
        actionDictionary["messageUrl"] = messageUrl
        actionDictionary["created_at"] = (createdAt?.timeIntervalSince1970)! * 1000
        actionDictionary["modified_at"] = (modifiedAt?.timeIntervalSince1970)! * 1000
        return actionDictionary
    }
    
    init(member: Account, type: ActionType, message: String?, messageUrl: String?) {
        super.init()
        self.member = member
        self.type = type
        self.message = message
        self.messageUrl = messageUrl
    }
    
}
