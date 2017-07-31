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
    
    init(dictionary: NSDictionary) {
        lat = dictionary["lat"] as? Double
        lng = dictionary["lng"] as? Double
    }
    
    init(json: JSON) {
        lat = json["lat"].doubleValue
        lng = json["lng"].doubleValue
    }
    
    init(location: CLLocationCoordinate2D) {
        lat = location.latitude
        lng = location.longitude
    }
    
    func toPositionDictionary() -> NSDictionary {
        var positionDictionary = [String: Double]()
        positionDictionary["lat"] = lat
        positionDictionary["lng"] = lng
        return positionDictionary as NSDictionary
    }
}
