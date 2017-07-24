//
//  Step.swift
//  Fich
//
//  Created by admin on 7/24/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class Step: NSObject {
    var json: JSON?
    var distance: String?
    var duration: String?
    var startLocation: Position?
    var endLocation: Position?
    var instruction: String?
    var polyline: GMSPolyline?
    var travelMode: String?
    
    init(json: JSON){
        self.json = json
        self.distance = json["distance"]["text"].stringValue
        self.duration = json["duration"]["text"].stringValue
        let startPosition = json["start_location"]
        startLocation = Position(json: startPosition)
        let endPosition = json["end_location"]
        endLocation = Position(json: endPosition)
        self.instruction = json["html_instruction"].stringValue
        
        let points = json["polyline"]["points"].stringValue
        let path = GMSPath.init(fromEncodedPath: points)
        self.polyline = GMSPolyline.init(path: path)
        
        self.travelMode = json["travel_mode"].stringValue
    }
    
    class func stepsWithArray(jsons : [JSON]) -> [Step]{
        var steps = [Step]()
        for json in jsons{
            let step = Step(json: json)
            steps.append(step)
        }
        return steps
    }
}
