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
import Alamofire
import SwiftyJSON

class InitialTripViewController: UIViewController {

    // MARK: *** Local variables
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var tableDataSource: GMSAutocompleteTableDataSource!
    var resultsController: UITableViewController!
    var contentRect = CGRect.zero
    
    var startPoint : CGFloat!
    
    var depLocation: CLLocationCoordinate2D!
    var desLocation: CLLocationCoordinate2D!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: {
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
        
        placesClient = GMSPlacesClient.shared()
        
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.431573, longitude: -78.656894, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: mapUIView.bounds, camera: camera)
        mapView.delegate = self
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
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        reverseGeocodeCoordinate(coordinate: marker.position, marker: marker)
        marker.map = mapView
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
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.title = place.name
        marker.snippet = place.formattedAddress!
        
        if UserDefaults.standard.bool(forKey: "is_departure"){
            depLocation = place.coordinate
            departureSearch.resignFirstResponder()
            self.departureSearch.text = "\(place.name)"
            marker.icon = UIImage(named: "current_location_on_map")
        }else{
            desLocation = place.coordinate
            destinationSearch.resignFirstResponder()
            self.destinationSearch.text = "\(place.name)"
            marker.icon = UIImage(named: "destination_on_map")
        }
        marker.map = mapView
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,longitude: place.coordinate.longitude, zoom: zoomLevel)
        mapView.animate(to: camera)
        if depLocation != nil && desLocation != nil{
            drawPath(currentLocation: depLocation, destinationLoc: desLocation)
        }
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
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


