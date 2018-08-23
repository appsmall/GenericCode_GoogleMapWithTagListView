//
//  MapVC.swift
//  IntegrateGoogleMapWithTagList
//
//  Created by Rahul Chopra on 21/08/18.
//  Copyright © 2018 AppSmall. All rights reserved.
//

import UIKit
import GoogleMaps

class MapVC: UIViewController {

    var mapView = GMSMapView()
    weak var homeDelegate: HomeVC?
    var locationManager = CLLocationManager()
    var location: CLLocationCoordinate2D?       //"location" object used in HomeVC class
    
    //MARK:- VIEW CONTROLLER METHODS
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        setConstraintsOnMapView()
        mapView.delegate = self
        checkAuthStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let homeVC = homeDelegate {
            homeVC.mapVC = self
        }
        self.view.layoutIfNeeded()
    }
    
    //MARK:- CORE FUNCTIONS
    func setConstraintsOnMapView() {
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func checkAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //Focus map camera on user current location when the user authorized by location manager
    func focusCameraOnUserCurrentLocation(coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 12.0)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
    }
    
    func showMarkersAndInfoOfSelectedAttorneyInCategory(selectedCategory: String) {
        mapView.clear()   //Clear all mapView Markers from the map
        
        if let delegate = homeDelegate {
            if let selectedAttornies = delegate.attorniesDataArray[selectedCategory] as? [String : Any] {
                
                if let allSelectedCategoryData = selectedAttornies["data"] as? [String: Any] {
                    for eachUser in allSelectedCategoryData {
                        if let user = eachUser.value as? [String: Any] {
                            guard let coordinates = user["coordinates"] as? CLLocationCoordinate2D else {
                                return
                            }
                            
                            let marker = GMSMarker()
                            
                            marker.position = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                            var markerImage = UIImage()
                            if delegate.selectedCategoriesArray.isEmpty{
                                // No Category Selected
                                marker.isTappable = false
                                if let image = UIImage(named: "ic_gray")?.withRenderingMode(.alwaysOriginal) {
                                    markerImage = image
                                }
                            }else{
                                // At least one category selected
                                if selectedCategory == "Criminal" {
                                    
                                    if let image = UIImage(named: "ic_brinjle")?.withRenderingMode(.alwaysOriginal) {
                                        markerImage = image
                                    }
                                }
                                else if selectedCategory == "Bankruptcy" {
                                    
                                    if let image = UIImage(named: "ic_blue")?.withRenderingMode(.alwaysOriginal) {
                                        markerImage = image
                                    }
                                }
                                else if selectedCategory == "Employement" {
                                    
                                    if let image = UIImage(named: "ic_purple")?.withRenderingMode(.alwaysOriginal) {
                                        markerImage = image
                                    }
                                }
                                else {
                                    if let image = UIImage(named: "ic_gray")?.withRenderingMode(.alwaysOriginal) {
                                        markerImage = image
                                    }
                                }
                            }
                            
                            let markerView = UIImageView(image: markerImage)
                            markerView.frame.size = CGSize(width: 32, height: 32)
                            markerView.tintColor = UIColor.black
                            marker.iconView = markerView
                            
                            marker.userData = user
                            marker.appearAnimation = .pop
                            marker.map = self.mapView
                        }
                    }
                }
                
                
            }
        }
    }

    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}

//MARK:- LOCATION MANAGER DELEGATE METHODS
extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        
        if status == .authorizedAlways{
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        focusCameraOnUserCurrentLocation(coordinate: location.coordinate)
        self.location = location.coordinate
    }
}

//MARK:- MAPVIEW DELEGATE METHODS
extension MapVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Marker Tap")
        mapView.selectedMarker = marker
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("Marker Info Window Tap")
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        print("Marker Info Window")
        let markerView = MapMarkerInfoWindow(frame: CGRect(x: 0, y: 0, width: 150, height: 60))
        
        if let userData = marker.userData as? [String:Any] {
            if let name = userData["name"] as? String, let email = userData["email"] as? String {
                markerView.label.text = name
                markerView.emailLabel.text = email
            }
        }
        
        return markerView
    }
    
    @objc func markerAction(){
        print("Marker Btn Pressed")
    }
}
