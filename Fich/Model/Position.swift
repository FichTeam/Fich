//
//  Position.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/17/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class Position: NSObject {
    var lat: Double?
    var lng: Double?
    var name: String?
    var address: String?
    
    init(dictionary: [String : Any]) {
        lat = dictionary["lat"] as? Double
        lng = dictionary["lng"] as? Double
        name = dictionary["name"] as? String ?? ""
        address = dictionary["address"] as? String ?? ""
    }
    
    init(json: JSON) {
        lat = json["lat"].doubleValue
        lng = json["lng"].doubleValue
        name = json["name"].stringValue
        address = json["address"].stringValue
    }
    
    init(location: CLLocationCoordinate2D) {
        lat = location.latitude
        lng = location.longitude
    }
    
    init(loc: CLLocation) {
        lat = loc.coordinate.latitude
        lng = loc.coordinate.longitude
    }
    
    init(loc: CLLocationCoordinate2D, name: String, address: String) {
        lat = loc.latitude
        lng = loc.longitude
        self.name = name
        self.address = address
    }
    
    func toPositionDictionary() -> NSDictionary {
        var positionDictionary = [String: Double]()
        positionDictionary["lat"] = lat!
        positionDictionary["lng"] = lng!
        return positionDictionary as NSDictionary
    }
    
    func toPositionDictionaryDetail() -> NSDictionary{
        var positionDictionary = [String: Any]()
        positionDictionary["lat"] = lat!
        positionDictionary["lng"] = lng!
        positionDictionary["name"] = self.name!
        positionDictionary["address"] = self.address!
        return positionDictionary as NSDictionary
    }
}
