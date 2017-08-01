//
//  InitialTripViewController.swift
//  Fich
//
//  Created by admin on 7/18/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import CoreLocation

class InitialTripViewController: UIViewController {

    // MARK: *** Local variables
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    
    var tableDataSource: GMSAutocompleteTableDataSource!
    var resultsController: UITableViewController!
    var contentRect = CGRect.zero
    
    var startPoint : CGFloat!
    
    var depLocation: CLLocationCoordinate2D!
    var desLocation: CLLocationCoordinate2D!
    
    var stopsLocation = [Position]()
    
    private var dict: [String: GMSMarker] = [:]
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    
    
    @IBOutlet weak var departureSearch: UITextField!
    @IBOutlet weak var destinationSearch: UITextField!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var whereToLabel: UIView!
    @IBOutlet weak var resultView: UIView!
    
    
    
    // MARK: *** UI Events
    @IBAction func onBack(_ sender: UIButton) {
        whereToLabel.isHidden = false
        searchView.isHidden = true
        mapUIView.isHidden = false
        resultsController.view.isHidden = true
        
        whereToLabel.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.whereToLabel.alpha = 1.0
        }
    }
    
    @IBAction func onSetupWaypoints(_ sender: Any) {
        performSegue(withIdentifier: "segueToSetupWaypoints", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSetupWaypoints" {
            let dest = segue.destination as! WaypointsViewController
            dest.depPlace = departureSearch.text!
            dest.desPlace = destinationSearch.text!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 37.431573, longitude: -78.656894, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: mapUIView.bounds, camera: camera)
        mapView.delegate = self
        GoogleMapManager.shared.manage(mapView: self.mapView, mapUIView: mapUIView)
        UserDefaults.standard.setValue(nil, forKey: "is_map_loaded")
        setupLocationAndMap()
        
        self.tableDataSource = GMSAutocompleteTableDataSource()
        self.tableDataSource.delegate = self
        self.resultsController = UITableViewController(style: .plain)
        self.resultsController.tableView.delegate = tableDataSource
        self.resultsController.tableView.dataSource = tableDataSource
    }
    
    func viewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.searchView.frame.origin.y = self.searchView.frame.origin.y - self.searchView.frame.height
        whereToLabel.isHidden = true
        searchView.isHidden = false
        mapUIView.isHidden = false
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: [], animations: {
            self.searchView.frame.origin.y = self.searchView.frame.origin.y + self.searchView.frame.height
        }, completion: nil)
        
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
        
        
        whereToLabel.layer.shadowOffset = CGSize(width: -1, height: 1)
        whereToLabel.layer.shadowOpacity = 0.2
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        whereToLabel.addGestureRecognizer(tapGestureRecognizer)
        resultView.isHidden = true
        whereToLabel.isHidden = false
        searchView.isHidden = true
        departureSearch.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.departureSearch.delegate = self
        destinationSearch.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.destinationSearch.delegate = self
    }
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D, marker: GMSMarker) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let title = address.lines as [String]?
                marker.title = title?.first
            }
        }
    }
}

extension InitialTripViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        
        if UserDefaults.standard.string(forKey: "is_map_loaded") == nil{
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude, zoom: zoomLevel)
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                UserDefaults.standard.setValue("Map loaded", forKey: "is_map_loaded")
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

extension InitialTripViewController: GMSMapViewDelegate{
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
//
//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        reverseGeocodeCoordinate(coordinate: marker.position, marker: marker)
//        marker.map = mapView
//    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let thumbView: GoogleMapThumbView = GoogleMapThumbView()
        marker.tracksInfoWindowChanges = true
        if let id = marker.title {
            thumbView.titleLabel.text = id
            thumbView.snippetLabel.text = marker.snippet
        }
        return thumbView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print(marker.title!)
        if marker.snippet == "Not in your stops"{
            marker.snippet = "Added in your stops"
            let stop = Position(location: marker.position)
            stopsLocation.append(stop)
            FirebaseClient.sharedInstance.addStopToDatabase(dict: stop.toPositionDictionary())
            GoogleMapManager.shared.drawPathWithWaypoints(currentLocation: depLocation, destinationLoc: desLocation, waypoints: stopsLocation)
        }else{
            marker.snippet = "Not in your stops"
            let stop = Position(location: marker.position)
            stopsLocation.removeAll()
            FirebaseClient.sharedInstance.removeStopFromDatabase(dict: stop.toPositionDictionary())
            GoogleMapManager.shared.drawPathAgain(currentLocation: depLocation, destinationLoc: desLocation)
        }
        return false
    }
}

extension InitialTripViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == departureSearch{
            UserDefaults.standard.setValue(true, forKey: "is_departure")
        }else if textField == destinationSearch{
            UserDefaults.standard.setValue(false, forKey: "is_departure")
        }
        self.resultsController.view.isHidden = false
        self.mapView.isHidden = true
        self.addChildViewController(resultsController)
        self.resultsController.view.frame = resultView.frame
        self.resultsController.view.alpha = 0.0
        self.view.addSubview(resultsController.view)
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.resultsController.view.alpha = 1.0
        })
        resultsController.didMove(toParentViewController: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resultsController.willMove(toParentViewController: nil)
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.resultsController.view.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            self.resultsController.view.removeFromSuperview()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    func textFieldDidChange(_ textField: UITextField) {
        tableDataSource.sourceTextHasChanged(textField.text)
    }
}

extension InitialTripViewController: GMSAutocompleteTableDataSourceDelegate{
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        self.mapView.isHidden = false
        if UserDefaults.standard.bool(forKey: "is_departure"){
            depLocation = place.coordinate
            departureSearch.resignFirstResponder()
            self.departureSearch.text = "\(place.name)"
            GoogleMapManager.shared.addMarker(id: place.name, snippet: place.formattedAddress!, lat: place.coordinate.latitude, long: place.coordinate.longitude, imageName: "icon_dep")
        }else{
            desLocation = place.coordinate
            destinationSearch.resignFirstResponder()
            self.destinationSearch.text = "\(place.name)"
            GoogleMapManager.shared.addMarker(id: place.name, snippet: place.formattedAddress!, lat: place.coordinate.latitude, long: place.coordinate.longitude, imageName: "icon_des")
        }
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,longitude: place.coordinate.longitude, zoom: zoomLevel)
        mapView.animate(to: camera)
        if depLocation != nil && desLocation != nil{
            GoogleMapManager.shared.clearPath()
            GoogleMapManager.shared.drawPath(currentLocation: depLocation, destinationLoc: desLocation)
            GoogleMapManager.shared.showSuggestStops(currentLocation: depLocation, destinationLoc: desLocation)
        }
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("Load error: \(error.localizedDescription)")
        if UserDefaults.standard.bool(forKey: "is_departure"){
            departureSearch.resignFirstResponder()
            self.departureSearch.text = ""
        }else{
            destinationSearch.resignFirstResponder()
            self.destinationSearch.text = ""
        }
    }
    
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        resultsController.tableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        resultsController.tableView.reloadData()
    }
}


