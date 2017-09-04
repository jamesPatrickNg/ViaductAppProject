//
//  RiderViewController.swift
//  Viaduct For Rider
//
//  Created by James-Patrick Ngoupayou on 25/08/2017.
//  Copyright © 2017 James-Patrick Ngoupayou. All rights reserved.
//

import UIKit
import MapKit

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CabController {

    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var callCabButton: UIButton!
    
    
    private var locationManager = CLLocationManager();
    private var userLocation : CLLocationCoordinate2D?;
    private var driverLocation : CLLocationCoordinate2D?;
    
    private var timer = Timer() ;

    private var riderCanRequestACab = true ;
    private var riderCanceledRequest = false ;
    
    private var appStartedForTheFirstTime = true;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager();
        CabHandler.Instance.observeMessagesForRider();
        CabHandler.Instance.delegate = self;
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
            
            if driverLocation != nil {
                print(driverLocation!);
                print(riderCanRequestACab);
                if !riderCanRequestACab{
                    let driverAnnotations = MKPointAnnotation() ;
                    driverAnnotations.coordinate = driverLocation! ;
                    driverAnnotations.title = "Driver Location" ;
                    print("UPDATING DRIVER LOCATION ON MAP");
                    myMap.addAnnotation( driverAnnotations); 
                }
            }
            
            let annotation = MKPointAnnotation() ;
            annotation.coordinate = userLocation!;
            annotation.title = "My Location";
            myMap.showsUserLocation = true ;
            //myMap.addAnnotation(annotation);
        }
    }
    
    func updateRidersLocation() {
        CabHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude) ;
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        self.driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    func canCallCab(delegateCalled: Bool) {
        if delegateCalled{
            callCabButton.setTitle("CANCEL MY RIDE", for: UIControlState.normal);
            riderCanRequestACab = false;
        }else {
            callCabButton.setTitle("REQUEST PICKUP NOW", for: UIControlState.normal);
            riderCanRequestACab = true ;
        }
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String,latitude : Double, longitude :Double) {
        if !riderCanceledRequest{
            if requestAccepted {
                alertTheUser(title: "Ride accepted", message: "\(driverName) Has Accepted Your Ride Request. Do Not Move. He Is On Is Way.");
                self.driverLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
                
            }else {
                CabHandler.Instance.cancelCab();
                timer.invalidate();
                alertTheUser(title: "Ride canceled", message: "\(driverName) Has Canceled Your Ride Request")
            }
        }
        riderCanceledRequest = false ;
    }
    
    
    
    @IBAction func callUber(_ sender: AnyObject) {
        if userLocation != nil {
            if riderCanRequestACab {
                CabHandler.Instance.requestCab(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(RiderViewController.updateRidersLocation), userInfo: nil, repeats: true) ;
                
            }else {
                riderCanceledRequest = true ;
                CabHandler.Instance.cancelCab();
                timer.invalidate();
            }
        }
    }


    @IBAction func logOut(_ sender: AnyObject) {
        if AuthProvider.Instance.logOut() {
            
            if !riderCanRequestACab {
                CabHandler.Instance.cancelCab();
                timer.invalidate();
            }
            
            dismiss(animated: true, completion: nil)
        }else {
            //proble with log in out
            alertTheUser(title: "Could not log out", message: "We could not log out at the moment, please try again later ")
        }
    }
    
    /**
     This function print an alert message to the user screen
     */
    private func alertTheUser (title : String, message: String){
        //Here we create an alert with the title and the message that we specified in the parameters.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        //Here we create a button
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        //Here we add the button to the alert
        alert.addAction(ok);
        // Here we put the alert on the user screen
        present(alert, animated: true, completion: nil);
    }

}

























