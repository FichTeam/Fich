//
//  GoogleMapManager.swift
//  Fich
//
//  Created by admin on 7/21/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class GoogleMapManager{
    static let shared: GoogleMapManager = GoogleMapManager()
    private var mapView: GMSMapView?
    var polylines :[GMSPolyline] = []
    var steps: [Step] = []
    var suggestStop: [Stop] = []
    var zoomLevel: Float = 15.0
    let googleKey = "AIzaSyDS6D8L6lUZ3mZwb1B496I1bjonpGL2jVc"
    private init(){}

    private var dictDep: [String: GMSMarker] = [:]
    private var dictDes: [String: GMSMarker] = [:]
    private var dictStop: [String: GMSMarker] = [:]
    
    func manage(mapView: GMSMapView, mapUIView: UIView) {
        self.mapView = mapView
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.isBuildingsEnabled = false
        
        do {
            if let styleURL = Bundle.main.url(forResource: "darkBlueStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    func addMarker(id: String, snippet: String, lat: Double, long: Double, imageName: String) {
        if imageName == "icon_dep"{
            if dictDep.count == 0{
                let cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let marker = GMSMarker(position: cllocation)
                self.dictDep[imageName] = marker
                marker.map = mapView
                let image = UIImage(named: imageName)
                marker.icon = image
                marker.title = id
                marker.snippet = snippet
            }else{
                let markerTest = getMarker(id: imageName)
                markerTest?.position.latitude = lat
                markerTest?.position.longitude = long
                markerTest?.title = id
                markerTest?.snippet = snippet
            }
        }else if imageName == "icon_des"{
            if dictDes.count == 0{
                let cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let marker = GMSMarker(position: cllocation)
                self.dictDes[imageName] = marker
                marker.map = mapView
                let image = UIImage(named: imageName)
                marker.icon = image
                marker.title = id
                marker.snippet = snippet
            }else{
                let markerTest = getMarker(id: imageName)
                markerTest?.position.latitude = lat
                markerTest?.position.longitude = long
                markerTest?.title = id
                markerTest?.snippet = snippet
            }
        }else if imageName == "location_stop_w"{
            let cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let marker = GMSMarker(position: cllocation)
            marker.map = mapView
            let image = UIImage(named: imageName)
            marker.icon = image
            marker.title = id
            marker.snippet = snippet
        }
    }
    func getMarker(id:String) -> GMSMarker? {
        if id == "icon_dep"{
            return dictDep[id]
        }else if id == "icon_des"{
            return self.dictDes[id]
        }else{
            return nil
        }
    }
    func drawPath(currentLocation: CLLocationCoordinate2D, destinationLoc : CLLocationCoordinate2D)
    {
        let ori = Position(location: currentLocation)
        let des = Position(location: destinationLoc)
        let tripDict: NSDictionary = [
            "user_id": FirebaseClient.sharedInstance.getUserUID()!,
            "source" : ori.toPositionDictionary(),
            "destination" : des.toPositionDictionary()
        ]
        FirebaseClient.sharedInstance.createTripWithDict(dict: tripDict)
        
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "\(destinationLoc.latitude),\(destinationLoc.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(googleKey)"
        
        Alamofire.request(url).responseJSON { response in
            //print(response.request!)  // original URL request
            //print(response.response!) // HTTP URL response
            //print(response.data!)     // server data
            //print(response.result)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeColor = UIColor(rgb: 0xe3e3e3)
                polyline.strokeWidth = 3.5
                polyline.map = self.mapView
                self.polylines.append(polyline)
                
                let legs = route["legs"].arrayValue
                for leg in legs {
                    let stepsJSON = leg["steps"].arrayValue
                    self.steps = Step.stepsWithArray(jsons: stepsJSON)
                    print(self.steps)
                }
            }
        }
    }
    
    func drawPathAgain(currentLocation: CLLocationCoordinate2D, destinationLoc : CLLocationCoordinate2D)
    {
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "\(destinationLoc.latitude),\(destinationLoc.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(googleKey)"
        clearPath()
        Alamofire.request(url).responseJSON { response in
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeColor = UIColor(rgb: 0xe3e3e3)
                polyline.strokeWidth = 3.5
                polyline.map = self.mapView
                self.polylines.append(polyline)
                
                let legs = route["legs"].arrayValue
                for leg in legs {
                    let stepsJSON = leg["steps"].arrayValue
                    self.steps = Step.stepsWithArray(jsons: stepsJSON)
                    print(self.steps)
                }
            }
        }
    }
    
    func drawPathWithWaypoints(currentLocation: CLLocationCoordinate2D, destinationLoc : CLLocationCoordinate2D, waypoints: [Position])
    {
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "\(destinationLoc.latitude),\(destinationLoc.longitude)"
        var stopsString = ""
        for wp in waypoints{
            let loc = "\(wp.lat!),\(wp.lng!)"
            stopsString += loc
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&waypoints=\(stopsString)&key=\(googleKey)"
        //let url2 = "https://maps.googleapis.com/maps/api/directions/json?origin=Boston,MA&destination=Concord,MA&waypoints=Charlestown,MA|Lexington,MA&key=AIzaSyDS6D8L6lUZ3mZwb1B496I1bjonpGL2jVc"
        clearPath()
        
        Alamofire.request(urlString).responseJSON { response in
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeColor = UIColor(rgb: 0xe3e3e3)
                polyline.strokeWidth = 3.5
                polyline.map = self.mapView
                self.polylines.append(polyline)
                
                let legs = route["legs"].arrayValue
                for leg in legs {
                    let stepsJSON = leg["steps"].arrayValue
                    self.steps = Step.stepsWithArray(jsons: stepsJSON)
                    print(self.steps)
                }
            }
        }
    }
    
    func clearPath(){
        if polylines.count > 0 {
            for i in 0...polylines.count-1{
                polylines[i].map = nil
            }
            self.polylines.removeAll()
        }
    }
    
    func showSuggestStops(currentLocation: CLLocationCoordinate2D, destinationLoc : CLLocationCoordinate2D){
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        //let destination = "\(destinationLoc.latitude),\(destinationLoc.longitude)"
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(origin)&radius=10000&types=food,hospital,gas_station&key=\(googleKey)"
        
        Alamofire.request(url).responseJSON { response in
            let json = JSON(data: response.data!)
            let stopsJSON = json["results"].arrayValue
            self.suggestStop = Stop.stopsWithArray(jsons: stopsJSON)
            for stop in self.suggestStop{
                let cllocation = CLLocationCoordinate2D(latitude: (stop.location?.lat)!, longitude: (stop.location?.lng)!)
                
                if (cllocation.latitude < destinationLoc.latitude && cllocation.latitude > currentLocation.latitude) || (cllocation.latitude > destinationLoc.latitude && cllocation.latitude < currentLocation.latitude) || (cllocation.longitude < destinationLoc.longitude && cllocation.longitude > currentLocation.longitude)
                || (cllocation.longitude > destinationLoc.longitude && cllocation.longitude < currentLocation.longitude){
                    GoogleMapManager.shared.addMarker(id: stop.name!, snippet: stop.placeId!, lat: cllocation.latitude, long: cllocation.longitude, imageName: "location_stop_w")
                }
            }
            
            
            
            let nextPageToken = json["next_page_token"].stringValue
            var count = 0
            while nextPageToken.count > 0 && count < 2{
                count = count + 1
                let urlNextPage = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(nextPageToken)&key=\(self.googleKey)"
                Alamofire.request(urlNextPage).responseJSON { response in
                    let stopsJSON = json["results"].arrayValue
                    self.suggestStop = Stop.stopsWithArray(jsons: stopsJSON)
                    for stop in self.suggestStop{
                        let cllocation = CLLocationCoordinate2D(latitude: (stop.location?.lat)!, longitude: (stop.location?.lng)!)
                        if (cllocation.latitude < destinationLoc.latitude && cllocation.latitude > currentLocation.latitude) || (cllocation.latitude > destinationLoc.latitude && cllocation.latitude < currentLocation.latitude) || (cllocation.longitude < destinationLoc.longitude && cllocation.longitude > currentLocation.longitude)
                            || (cllocation.longitude > destinationLoc.longitude && cllocation.longitude < currentLocation.longitude){
                            GoogleMapManager.shared.addMarker(id: stop.name!, snippet: stop.placeId!, lat: cllocation.latitude, long: cllocation.longitude, imageName: "location_stop_w")
                        }
                    }
                }
            }
            
        }
    }
}
