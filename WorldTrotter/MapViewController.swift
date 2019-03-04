//
//  MapViewController.swift
//  WorldTrotter
//
//  Created by July on 3/1/19.
//  Copyright © 2019 July. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    //keeps track of current pin index:
    var selectedAnnotationIndex: Int = -1
    
    let standardString = NSLocalizedString("Standard", comment: "Standard map view")
    let satelliteString = NSLocalizedString("Satellite", comment: "Satellite map view")
    let hybridString = NSLocalizedString("Hybrid", comment: "Hybrid map view")
    let currentLocationString = NSLocalizedString("CurrentLocation", comment: "Button for current location")
    let pinString = NSLocalizedString("Pin", comment: "Pin icon on map")
    let NYCString = NSLocalizedString("NYC", comment: "New York City")
    let LondonString = NSLocalizedString("London", comment: "London")
    let TokyoString = NSLocalizedString("Tokyo", comment: "Tokyo")
    
    override func loadView() {
        mapView = MKMapView()
        mapView.delegate = self
        locationManager = CLLocationManager()
        
        // set it as *the* view of this view controller
        view = mapView
        
        
        let segmentedControl = UISegmentedControl(items: [standardString, satelliteString, hybridString])
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self,
                                   action: #selector(MapViewController.mapTypedChanged(_:)),
                                   for: UIControlEvents.valueChanged)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        initLocalizationButton(segmentedControl)
        intitMapPins(segmentedControl)

        let topConstraint = segmentedControl.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8)
        let margin = view.layoutMarginsGuide
        let leadingConstraint = segmentedControl.leadingAnchor.constraint(equalTo: margin.leadingAnchor)
        let trailingConstraint = segmentedControl.trailingAnchor.constraint(equalTo: margin.trailingAnchor)
        
        topConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        
        //mapView.userTrackingMode = .follow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapViewController loaded its view.")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        
        if hour > 17 || hour < 6 {
            self.view.backgroundColor=UIColor.darkGray
        }
    }
    
    @objc func mapTypedChanged(_ segControl: UISegmentedControl) {
        switch segControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            break
        }
    }
    
    func initLocalizationButton(_ anyView: UIView!) {
        let localizationButton = UIButton.init(type: .system)
        localizationButton.setTitle(currentLocationString, for: UIControlState.normal)
        localizationButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(localizationButton)
        
        //Constraints
        let topConstraint = localizationButton.topAnchor.constraint(equalTo: anyView.topAnchor, constant: 32)
        let leadingConstraint = localizationButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        let trailingConstraint = localizationButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        
        topConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        localizationButton.addTarget(self, action: #selector(MapViewController.showLocalization(sender:)), for: .touchUpInside)
    }

    @objc func showLocalization(sender: UIButton!){
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
    }
    
    @objc func intitMapPins(_ anyView: UIView!) {
        //create array of location objects:
        var locations = [Locations]()
        locations.append(Locations(name: NYCString, lat: 40.730872, long: -74.003066))
        locations.append(Locations(name: LondonString, lat: 51.5074, long: 0.1278))
        locations.append(Locations(name: TokyoString, lat: 35.6895, long: 139.6917))
        
        //drop location pins onto map:
        for location in locations {
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = CLLocationCoordinate2DMake(location.lat, location.long)
            dropPin.title = location.name
            mapView.addAnnotation(dropPin)
        }

        //create button to toggle pins:
        let pinButton = UIButton(type: .system)
        pinButton.setTitle(pinString, for: .normal)
        pinButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        pinButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        pinButton.translatesAutoresizingMaskIntoConstraints = false
        pinButton.addTarget(self, action: #selector(selectPin(_:)), for: .touchUpInside)
        
        //NSGenericException
        //        pinButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -8).isActive = true
        //        pinButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true

    }
    
    @objc func selectPin(_ button: UIButton) {
        //data checks:
        if !(mapView.annotations.count > 0) {
            return
        }
        
        //go to next annotation or back to start if last one:
        selectedAnnotationIndex += 1
        if selectedAnnotationIndex >= mapView.annotations.count {
            selectedAnnotationIndex = 0
        }
        
        //select pin and animate map:
        let annotation = mapView.annotations[selectedAnnotationIndex]
        let zoomedInCurrentLocation = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 5000, 5000)
        mapView.setRegion(zoomedInCurrentLocation, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //This is a method from MKMapViewDelegate, fires up when the user`s location changes
        let zoomedInCurrentLocation = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2500, 2500)
        mapView.setRegion(zoomedInCurrentLocation, animated: true)
    }
}

struct Locations {
    var name: String
    var lat: Double
    var long: Double
    
    init(name: String, lat: Double, long: Double) {
        self.name = name
        self.lat = lat
        self.long = long
    }
}

