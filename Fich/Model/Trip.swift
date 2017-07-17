//
//  Trip.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation

enum TripStatus: String {
    case prepare = "PREPARE", run = "RUN", finish = "FINISH"
}

class Trip: DataObject {
    var id: String?
    var name: String?
    var status: TripStatus?
    var phoneNumber: String?
    var startTime: Date?
    var endTime: Date?
    var source: Position?
    var destination: Position?
    var stops = [Position]()
    var members = [String: Account]()
    
    override init(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        id = dictionary["account_id"] as? String
        name = dictionary["name"] as? String
        let statusString = dictionary["status"] as? String
        if let statusString = statusString {
            status = TripStatus(rawValue: statusString)
        }
        phoneNumber = dictionary["phone_number"] as? String
        let startTimeDouble = dictionary["start_time"] as? Double
        if let startTimeDouble = startTimeDouble {
            startTime = Date(timeIntervalSince1970: startTimeDouble/1000)
        }
        let endTimeDouble = dictionary["end_time"] as? Double
        if let endTimeDouble = endTimeDouble {
            endTime = Date(timeIntervalSince1970: endTimeDouble/1000)
        }
        let sourcePosition = dictionary["source"] as? NSDictionary
        if let sourcePosition = sourcePosition {
            source = Position(dictionary: sourcePosition)
        }
        let destinationPosition = dictionary["destination"] as? NSDictionary
        if let destinationPosition = destinationPosition {
            destination = Position(dictionary: destinationPosition)
        }
        let stopArray = dictionary["stops"] as? [NSDictionary]
        if let stopArray = stopArray {
            for stopPostion in stopArray {
                stops.append(Position(dictionary: stopPostion))
            }
        }
        let memberDictionary = dictionary["members"] as? NSDictionary
        if let memberDictionary = memberDictionary {
            for (key, memberDic) in memberDictionary {
                let member = Account(dictionary: memberDic as! NSDictionary)
                members[key as! String] = member
            }
        }
    }
    
    func toTripDictionary() -> NSDictionary {
        var tripDictionary = [String: Any]()
        tripDictionary["id"] = id
        tripDictionary["name"] = name
        tripDictionary["status"] = status?.rawValue
        tripDictionary["phone_number"] = phoneNumber
        tripDictionary["start_time"] = (startTime?.timeIntervalSince1970)! * 1000
        tripDictionary["end_time"] = (endTime?.timeIntervalSince1970)! * 1000
        tripDictionary["source"] = source?.toPositionDictionary()
        tripDictionary["destination"] = destination?.toPositionDictionary()
        tripDictionary["created_at"] = (createdAt?.timeIntervalSince1970)! * 1000
        tripDictionary["modified_at"] = (modifiedAt?.timeIntervalSince1970)! * 1000
//        tripDictionary["stops"] = phoneNumber
        return tripDictionary as NSDictionary
    }
}
