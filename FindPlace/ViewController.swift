//
//  ViewController.swift
//  FindPlace
//
//  Created by Jin on 8/31/17.
//  Copyright © 2017 Jin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate,UITextFieldDelegate,CLLocationManagerDelegate {
    struct Constant {
        static let MKAnnotationIdentifier = "MKAnnotationIdentifier"
    }
    @IBOutlet weak var textField: UITextField!{
        didSet{
            textField.delegate = self
        }
    }
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.delegate = self
            mapView.mapType = .standard
        }
    }
    private var searchString:String?{
        didSet{
            if searchString != nil, !searchString!.isEmpty {
                let request = MKLocalSearchRequest()
                request.naturalLanguageQuery = searchString
                request.region = currentRegionWith(radiusInKm: 10)
                mapView.setRegion(request.region, animated: true)
                let search = MKLocalSearch(request: request)
                search.start(completionHandler: { [weak weakSelf = self] (response, error) in
                    if error != nil {
                        print(error!)
                    }
                    if let items = response?.mapItems{
                        weakSelf?.mapView?.addAnnotations(items)
                        weakSelf?.mapView?.showAnnotations(items, animated: true)
                    }
                })
            }
        }
    }
    
    private var locationManager:CLLocationManager?
    
    private var myLocation:MKMapItem?{
        willSet{
            if myLocation != nil {
                mapView.removeAnnotation(myLocation!)
            }
        }
        didSet{
            if myLocation != nil{
                mapView.addAnnotation(myLocation!)
            }
            else{
                locationManager?.startUpdatingLocation()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest //change this as needed
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchString = "food"
    }
    
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view:MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Constant.MKAnnotationIdentifier)
        if view == nil {
            view = IconPinAnnotationView(annotation: annotation, reuseIdentifier: Constant.MKAnnotationIdentifier)
            view.canShowCallout = true
        }
        else{
            view.annotation = annotation
        }
        
        var pinImage:UIImage?
        
        switch searchString ?? "" {//to be changed in the future
        case "gas":
            pinImage = UIImage(named: "gas_pin")
        case "food":
            pinImage = UIImage(named: "food_pin")
        default:
            pinImage = UIImage(named: "favorite_pin")
        }
        if let item = annotation as? MKMapItem{
            if let name = item.name , name == "my location"{
                pinImage = UIImage(named: "my")
            }
        }
        view.image = pinImage
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    private func currentRegionWith(radiusInKm:Double) -> MKCoordinateRegion{
        var region = MKCoordinateRegion()
        region.center = myLocation?.coordinate ?? mapView.centerCoordinate
        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        return region
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if location != nil {
            let myloca = MKMapItem(placemark: MKPlacemark(coordinate: (location?.coordinate)!))
            myloca.name = "my location"
            myloca.phoneNumber = ""
            if myLocation == nil {
                myLocation = myloca
                locationManager?.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location servers error \(error)")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text{
            if !text.isEmpty && text != searchString{
                mapView.removeAnnotations(mapView.annotations)
                searchString = textField.text
                myLocation = nil
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func cancelKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
}

extension MKMapItem: MKAnnotation{
    public var title:String?{
        return name
    }
    public var subtitle:String?{
        return phoneNumber
    }
    public var coordinate:CLLocationCoordinate2D{
        return placemark.coordinate
    }
}

