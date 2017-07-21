//
//  GoogleMapManager.swift
//  Fich
//
//  Created by admin on 7/21/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import Foundation
import GoogleMaps
import Alamofire
import SwiftyJSON

class GoogleMapManager{
    static let shared: GoogleMapManager = GoogleMapManager()
    private var mapView: GMSMapView?
    var polylines :[GMSPolyline] = []
    var zoomLevel: Float = 15.0
    private init(){}

    private var dictDep: [String: GMSMarker] = [:]
    private var dictDes: [String: GMSMarker] = [:]
    
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
        if imageName == "current_location_on_map"{
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
        }else if imageName == "destination_on_map"{
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
        }
    }
    func getMarker(id:String) -> GMSMarker? {
        if id == "current_location_on_map"{
            return dictDep[id]
        }else{
            return self.dictDes[id]
        }
    }
    func drawPath(currentLocation: CLLocationCoordinate2D, destinationLoc : CLLocationCoordinate2D)
    {
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "\(destinationLoc.latitude),\(destinationLoc.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCTthE5Qltk1FES2HT86xRN0ix1a6Epfe4"
        
        Alamofire.request(url).responseJSON { response in
            print(response.request!)  // original URL request
            print(response.response!) // HTTP URL response
            print(response.data!)     // server data
            print(response.result)   // result of response serialization
            
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
}

