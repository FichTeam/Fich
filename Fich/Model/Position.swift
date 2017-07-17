//
//  Position.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/17/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class Position: NSObject {
    var lat: Double?
    var lon: Double?
    
    init(dictionary: NSDictionary) {
        lat = dictionary["lat"] as? Double
        lon = dictionary["lon"] as? Double
    }
    
    func toPositionDictionary() -> NSDictionary {
        var positionDictionary = [String: Double]()
        positionDictionary["lat"] = lat
        positionDictionary["lon"] = lon
        return positionDictionary as NSDictionary
    }
}
