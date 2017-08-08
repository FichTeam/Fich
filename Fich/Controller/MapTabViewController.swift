//
//  MapTabViewController.swift
//  Fich
//
//  Created by admin on 8/2/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import CoreLocation
import AudioToolbox

class MapTabViewController: UIViewController {
    
    
    @IBOutlet weak var mapUIView: UIView!
    var memberMarker = [GMSMarker]()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let MAX_RANGE = 2000.0
    
    @IBAction func onBack(_ sender: UIButton) {
        FirebaseClient.sharedInstance.leaveTrip(tripId: tripId)
        dismiss(animated: true, completion: nil)
    }
    
    
    var tripId: String! {
        didSet {
            tripRef = Database.database().reference().child("trip").child(tripId)
            observeTrip()
        }
    }
    
    var tripRef: DatabaseReference?
    var tripRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 37.431573, longitude: -78.656894, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: mapUIView.bounds, camera: camera)
        mapView.delegate = self
        GoogleMapManager.shared.manage(mapView: self.mapView, mapUIView: mapUIView)
        UserDefaults.standard.setValue(nil, forKey: "is_map_member_loaded")
        setupLocationAndMap()
    }
    
    func setupLocationAndMap(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        
        mapUIView.addSubview(mapView)
        mapView.isHidden = true
    }
    
    deinit {
        if let refHandle = tripRefHandle {
            tripRef?.removeObserver(withHandle: refHandle)
        }
    }
}

extension MapTabViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if (marker.snippet?.contains("https"))!{
            let thumbAvatarView: GoogleMapThumbAvaView = GoogleMapThumbAvaView()
            marker.tracksInfoWindowChanges = true
            if let id = marker.title {
                thumbAvatarView.titleLabel.text = id
                thumbAvatarView.avatar.setImageWith(URL(string: marker.snippet!)!)
            }
            return thumbAvatarView
        }else{
            let thumbView: GoogleMapThumbView = GoogleMapThumbView()
            marker.tracksInfoWindowChanges = true
            if let id = marker.title {
                thumbView.titleLabel.text = id
                thumbView.snippetLabel.text = marker.snippet
            }
            return thumbView
        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print(marker.title!)
        return false
    }
}



extension MapTabViewController {
    func observeTrip() {
        
        tripRefHandle = tripRef?.observe(.value, with: { (snapshot) in
            let tripDict = snapshot.value as? [String: Any]
            if let tripData = tripDict {
                let trip = Trip(dictionary: tripData)
                
                if let origin = trip.source{
                    GoogleMapManager.shared.addMarker(id: origin.name!, snippet: origin.address!, lat: origin.lat!, long: origin.lng!, imageName: "icon_dep")
                }
                if let destination = trip.destination{
                    GoogleMapManager.shared.addMarker(id: destination.name!, snippet: destination.address!, lat: destination.lat!, long: destination.lng!, imageName: "icon_des")
                }
                
                if trip.stops.count > 0{
                    for stop in trip.stops{
                        GoogleMapManager.shared.addMarker(id: stop.name!, snippet: stop.address!, lat: stop.lat!, long: stop.lng!, imageName: "location_stop_w")
                    }
                }
                if trip.source != nil && trip.destination != nil{
                    let origin = CLLocationCoordinate2D(latitude: (trip.source?.lat!)!, longitude: (trip.source?.lng!)!)
                    let destination = CLLocationCoordinate2D(latitude: (trip.destination?.lat!)!, longitude: (trip.destination?.lng!)!)
                    if trip.stops.count > 0{
                        GoogleMapManager.shared.drawPathWithWaypoints(currentLocation: origin, destinationLoc: destination, waypoints: trip.stops)
                    }else{
                        GoogleMapManager.shared.drawPathAgain(currentLocation: origin, destinationLoc: destination)
                    }
                }
                
                FirebaseClient.sharedInstance.getAllMemberPosition(tripid: self.tripId, success: { (position) in
                    if position.count > 0{
                        for po in 0...position.count-1{
                            if self.memberMarker.count == position.count {
                                for i in 0...self.memberMarker.count-1{
                                    let position2d = CLLocationCoordinate2D(latitude: position[i].lat!, longitude: position[i].lng!)
                                    self.memberMarker[i].position = position2d
                                }
                            }else{
                                let position2d = CLLocationCoordinate2D(latitude: position[po].lat!, longitude: position[po].lng!)
                                let marker = GMSMarker(position: position2d)
                                marker.map = self.mapView
                                let image = UIImage(named: "man-marker")
                                marker.icon = image
                                marker.title = position[po].name!
                                marker.snippet = position[po].address!
                                self.memberMarker.append(marker)
                            }
                        }
                        FirebaseClient.sharedInstance.getAllPosition(tripid: self.tripId, success: { (posit) in
                            print("is lost \(self.isLostConnection(posit: posit))")
                            if self.isLostConnection(posit: posit){
                                AudioServicesPlayAlertSound(SystemSoundID(1015))
                                AudioServicesPlayAlertSound(SystemSoundID(1016))
                                BleApi.sharedInstance.blink()
                            }
                        })
                    }
                })
                
            } else {
                print("error to decode trip. stop trip")
            }
            
        })
    }
    func calculateDistance(location1 : Position, location2: Position)->CLLocationDistance{
        let pos1 = CLLocation(latitude: location1.lat!, longitude: location1.lng!)
        let pos2 = CLLocation(latitude: location2.lat!, longitude: location2.lng!)
        let distanceMeters = pos1.distance(from: pos2)
        print("Distance is \(distanceMeters)")
        return distanceMeters
    }
    func isLostConnection(posit : [Position])->Bool{
        if posit.count > 1{
            for i in 0...posit.count-2{
                for j in (i+1)...posit.count-1{
                    if self.calculateDistance(location1: posit[i], location2: posit[j]) > MAX_RANGE{
                        return true
                    }
                }
            }
        }
        
        return false
    }
}

extension MapTabViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        FirebaseClient.sharedInstance.memberUpdatePosition(tripid: tripId, cllocation: location)
        
        if UserDefaults.standard.string(forKey: "is_map_member_loaded") == nil{
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude, zoom: zoomLevel)
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                UserDefaults.standard.setValue("Map loaded", forKey: "is_map_member_loaded")
                mapView.animate(to: camera)
            }
        }
        
    }
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
