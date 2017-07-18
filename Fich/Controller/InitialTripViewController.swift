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
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0

    var departResultsViewController: GMSAutocompleteResultsViewController?
    var departSearchController: UISearchController?
    var destResultsViewController: GMSAutocompleteResultsViewController?
    var destSearchController: UISearchController?
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    
    @IBOutlet weak var departureSearch: UIView!
    @IBOutlet weak var destinationSearch: UIView!
    @IBOutlet weak var mapUIView: UIView!
    
    
    // MARK: *** UI Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationAndMap()
        setupSearchbar()
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
        mapView.isBuildingsEnabled = true
        mapUIView.addSubview(mapView)
        mapView.isHidden = true
    }
    
    func setupSearchbar(){
        departResultsViewController = GMSAutocompleteResultsViewController()
        departResultsViewController?.delegate = self
        
        departSearchController = UISearchController(searchResultsController: departResultsViewController)
        departSearchController?.searchResultsUpdater = departResultsViewController
        
        departureSearch.addSubview((departSearchController?.searchBar)!)
        departSearchController?.searchBar.sizeToFit()
        
        let leftConstraint = NSLayoutConstraint(item: departureSearch, attribute: .leading, relatedBy: .equal, toItem: departSearchController?.searchBar, attribute: .leading, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: departureSearch, attribute: .bottom, relatedBy: .equal, toItem: departSearchController?.searchBar, attribute: .bottom, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: departureSearch, attribute: .top, relatedBy: .equal, toItem: departSearchController?.searchBar, attribute: .top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: departureSearch, attribute: .trailing, relatedBy: .equal, toItem: departSearchController?.searchBar, attribute: .trailing, multiplier: 1, constant:0)
        departureSearch.addConstraints([leftConstraint, bottomConstraint, topConstraint, rightConstraint])
        
        departSearchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        
        //---------
        
        destResultsViewController = GMSAutocompleteResultsViewController()
        destResultsViewController?.delegate = self
        
        destSearchController = UISearchController(searchResultsController: destResultsViewController)
        destSearchController?.searchResultsUpdater = destResultsViewController
        
        destinationSearch.addSubview((destSearchController?.searchBar)!)
        destSearchController?.searchBar.sizeToFit()
        destSearchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
}

extension InitialTripViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
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
        marker.title = "Your stop"
        marker.snippet = "Update later"
        marker.map = mapView
    }
}

// Handle the user's selection.
extension InitialTripViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        departSearchController?.isActive = false
        destSearchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress!)")
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.title = place.name
        marker.snippet = place.formattedAddress!
        marker.map = mapView
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,longitude: place.coordinate.longitude, zoom: zoomLevel)
        mapView.animate(to: camera)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
