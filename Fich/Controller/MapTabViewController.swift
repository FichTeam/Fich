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

class MapTabViewController: UIViewController {
    
    
    @IBOutlet weak var mapUIView: UIView!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    
    @IBAction func onBack(_ sender: UIButton) {
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
        let thumbView: GoogleMapThumbView = GoogleMapThumbView()
        marker.tracksInfoWindowChanges = true
        if let id = marker.title {
            thumbView.titleLabel.text = id
            //thumbView.snippetLabel.text = ""
        }
        return thumbView
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
                    GoogleMapManager.shared.addMarker(id: "Origin", snippet: "Snippet", lat: origin.lat!, long: origin.lng!, imageName: "icon_dep")
                }
                if let destination = trip.destination{
                    GoogleMapManager.shared.addMarker(id: "Destination", snippet: "Snippet", lat: destination.lat!, long: destination.lng!, imageName: "icon_des")
                }
                
                if trip.stops.count > 0{
                    for stop in trip.stops{
                        GoogleMapManager.shared.addMarker(id: "Stop", snippet: "Snippet", lat: stop.lat!, long: stop.lng!, imageName: "location_stop_w")
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
                
            } else {
                print("error to decode trip. stop trip")
            }
            
        })
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
