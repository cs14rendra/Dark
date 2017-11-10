//
//  MapViewController.swift
//  Dark
//
//  Created by surendra kumar on 11/3/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FirebaseAuth

private let reusableIdentifire = "pin"

class MapViewController: UIViewController {

    @IBOutlet var map: MKMapView!
    @IBOutlet var myLocationButton: UIButton!
    let locationManager = CLLocationManager()
    var userlocation : CLLocation?
    let apiManager = APIManager.sharedInstanse
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.map.delegate = self
        locationManager.delegate = self
        self.apiManager.delegate = self
        self.map.showsUserLocation = true
        self.map.isUserInteractionEnabled = true
        locationManager.startUpdatingLocation()
     }
    
    @IBAction func userButton(_ sender: Any) {
        guard let location = userlocation else {return}
        self.centerLocation(location: location)
    }
    func centerLocation(location : CLLocation){
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
        map.setRegion(region, animated: true)
    }
    
    func createAnnotationforMapData(mapData : [MapData]){
        for item in mapData {
            if let location = item.location, let id = item.key{
                let annotation = UserAnnotation(title: "Direction | Chat", coordinate: location.coordinate, id: id)
                if id != Auth.auth().currentUser?.uid {
                    self.map.addAnnotation(annotation)
                } 
            }
        }
    }
}

extension MapViewController : APIManagerDelegate{
    func didLoadMapData(mapData: [MapData]) {
        let allAnnotation = self.map.annotations
        self.map.removeAnnotations(allAnnotation)
        self.createAnnotationforMapData(mapData: mapData)
    }
}

extension MapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let defaultAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: reusableIdentifire)
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableIdentifire) ?? defaultAnnotation
        if annotation is MKUserLocation {
            return nil
        }
        annotationView.image = UIImage(named: "anno")
        annotationView.canShowCallout = true
        
        let chat = UIButton()
        chat.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        chat.setImage(UIImage(named : "chat"), for: .normal)
        let direction = UIButton()
        direction.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        direction.setImage(UIImage(named : "map"), for: .normal)
        
        annotationView.rightCalloutAccessoryView = chat
        annotationView.leftCalloutAccessoryView = direction
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == view.rightCalloutAccessoryView){
            if let userAnnotation =  view.annotation as? UserAnnotation{
                let chatNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatNav") as! UINavigationController
                let dest = chatNav.viewControllers.first as! MessageViewController
                dest.recieverID = userAnnotation.id!
                dest.senderDisplayName = ""
                dest.senderId = Auth.auth().currentUser?.uid
                self.present(chatNav, animated: true, completion: nil)
            }
        }else {     // Left
            if let userannotation = view.annotation as? UserAnnotation{
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: userannotation.coordinate))
                destination.name = "user location"
                let regiondistance : CLLocationDistance = 1000
                let regionSpan = MKCoordinateRegionMakeWithDistance(userannotation.coordinate, regiondistance, regiondistance)
                let option  = [MKLaunchOptionsMapCenterKey:NSValue(mkCoordinate : regionSpan.center),MKLaunchOptionsMapSpanKey:NSValue(mkCoordinateSpan : regionSpan.span),MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking] as [String : Any]
                MKMapItem.openMaps(with: [destination], launchOptions: option)
            }
        }
    }
}

extension MapViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(image: UIImage(named: DARKImage.tmap.rawValue))
    }
}

extension MapViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userlocation = locations.first{
            self.userlocation = userlocation
        }
    }
}

