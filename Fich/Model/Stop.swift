//
//  Stop.swift
//  Fich
//
//  Created by admin on 7/29/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

class Stop: NSObject {
    var json: JSON?
    var id: String?
    var location: Position?
    var icon: String?
    var name: String?
    var placeId :String?
    
    init(json: JSON){
        self.json = json
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        let position = json["geometry"]["location"]
        location = Position(json: position)
        
        self.icon = json["icon"].stringValue
        self.placeId = json["place_id"].stringValue
    }
    
    class func stopsWithArray(jsons : [JSON]) -> [Stop]{
        var stops = [Stop]()
        for json in jsons{
            let stop = Stop(json: json)
            stops.append(stop)
        }
        return stops
    }
}
