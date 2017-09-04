//
//  DriverViewController.swift
//  Viaduct For Driver
//
//  Created by James-Patrick Ngoupayou on 25/08/2017.
//  Copyright © 2017 James-Patrick Ngoupayou. All rights reserved.
//

import UIKit
import MapKit

class DriverViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate, CabController {

    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var cancelCabButton: UIButton!
    
    
    private var locationManager = CLLocationManager();
    private var userLocation : CLLocationCoordinate2D?;
    private var riderLocation : CLLocationCoordinate2D?;
    
    private var timer =  Timer();
    
    private var driverHasAcceptedRequest = false ;
    private var driverHasCanceledRequest = false;
    private var appStartedForTheFirstTime = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager();
        CabHandler.Instance.delegate = self ;
        CabHandler.Instance.observeMessagesForDriver();
    }
    
    private func initializeLocationManager(){
        locationManager.delegate = self ;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the coordinate from the manager
        if let location = locationManager.location?.coordinate{
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)); 
            
            if appStartedForTheFirstTime {
                myMap.setRegion(region, animated: true);
            }
            appStartedForTheFirstTime = false;
            
            myMap.removeAnnotations(myMap.annotations);
            
            if riderLocation != nil {
                if driverHasAcceptedRequest {
                    let riderAnnotations = MKPointAnnotation() ;
                    riderAnnotations.coordinate = riderLocation! ;
                    riderAnnotations.title = "Rider Location" ;
                    myMap.addAnnotation( riderAnnotations);
                }
            }
            
            let annotation = MKPointAnnotation() ;
            annotation.coordinate = userLocation!;
            annotation.title = "Drivers Location";
            myMap.showsUserLocation = true ;

            //myMap.addAnnotation(annotation);
        }
    }
    
    func acceptCab(name : String , lat: Double, long: Double) {
        if !driverHasAcceptedRequest {
            
            //CONVERT COORDINATE 2D INTO CLLOCATION
            let getUserLat : CLLocationDegrees = userLocation!.latitude;
            let getUserLong : CLLocationDegrees = userLocation!.longitude;
            let getUserLocation : CLLocation = CLLocation(latitude: getUserLat, longitude: getUserLong);
            
            let getRiderLat : CLLocationDegrees = lat;
            let getRiderLong : CLLocationDegrees = long;
            let getRiderLocation : CLLocation = CLLocation(latitude: getRiderLat, longitude: getRiderLong);
            
            //CALCULATE DISTANCE IN METERS
            let distance : CLLocationDistance =  getUserLocation.distance(from: getRiderLocation);
            
            
            cabRequest(title: "Cab Request", message: "You have a request from \(name) who is located at \(Int(distance)) meters away from you. ", requestAlive: true)
        }
    }
    
    func riderHasCanceledCab(){
        if !driverHasCanceledRequest {
            // cancel the cab from driver perspective
            CabHandler.Instance.canceledCabForDriver();
            self.driverHasAcceptedRequest = false ;
            self.cancelCabButton.isHidden = true;
            cabRequest(title: "Course Canceled", message: "The Rider Has Canceled The Course", requestAlive: false);
            
        }
        driverHasCanceledRequest = false;
    }
    
    func rideHasAlreadyBeenAccepted(){
        if !driverHasCanceledRequest {
            // let the driver know that the cab has already been accepted by an other driver
            self.driverHasAcceptedRequest = false ;
            self.cancelCabButton.isHidden = true;
            cabRequest(title: "You are too slow", message: "The Ride Has Already Been Accepted by An Other Rider.", requestAlive: false);
            
        }
    }
    
    func driverHasCanceledCab (){
        driverHasAcceptedRequest = false ;
        cancelCabButton.isHidden = true ;
        //invalide timer
        timer.invalidate()
    }

    func updateRidersLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    func updateDriversLocation() {
        CabHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }

    
    @IBAction func cancel(_ sender: AnyObject) {
        if driverHasAcceptedRequest{
            driverHasCanceledRequest = true;
            cancelCabButton.isHidden = true ;
            CabHandler.Instance.canceledCabForDriver();
            
            //invalide timer
            timer.invalidate();
        }
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        if AuthProvider.Instance.logOut() {
            
            if driverHasAcceptedRequest{
                cancelCabButton.isHidden = true;
                CabHandler.Instance.canceledCabForDriver();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil)
        }else {
            //proble with log in out
            cabRequest(title:  "Could not log out", message: "We could not log out at the moment, please try again later ", requestAlive: false);
        }
    }

    private func cabRequest (title : String , message  : String , requestAlive : Bool) {
        
        let alert = UIAlertController(title: title,  message: message, preferredStyle: .alert);
        
        if requestAlive  {
            let accept = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: { (alertAction : UIAlertAction) in
                
                self.driverHasAcceptedRequest = true ;
                self.cancelCabButton.isHidden  = false ;
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(DriverViewController.updateDriversLocation), userInfo: nil, repeats: true) ;
                
                
                //inform that we accepted the ride
                CabHandler.Instance.cabAccepted(latitude: Double(self.userLocation!.latitude), longitude: Double(self.userLocation!.longitude), req_accepted : "true");
                
                
            });
            
            let cancel = UIAlertAction (title: "Refuse", style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(accept);
            alert.addAction(cancel);
        }else {
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil);
            alert.addAction(ok);
        }
        
        present(alert, animated:  true , completion: nil);
    }

    
}//class
