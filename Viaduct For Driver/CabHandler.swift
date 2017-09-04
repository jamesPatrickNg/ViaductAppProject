//
//  CabHandler.swift
//  Viaduct For Driver
//
//  Created by James-Patrick Ngoupayou on 31/08/2017.
//  Copyright © 2017 James-Patrick Ngoupayou. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CabController : class {
    func acceptCab (name : String , lat : Double , long : Double);
    func riderHasCanceledCab();
    func driverHasCanceledCab();
    func rideHasAlreadyBeenAccepted();
    func updateRidersLocation( lat : Double , long : Double);
}

class CabHandler  {
    private static let _instance =  CabHandler() ;
    
    weak var delegate : CabController? ;
    
    var rider = "";
    var driver = "";
    var driver_id =  "" ;
    var request_id = "" ;
    var cabAcceptedID = "";
    
    
    static var Instance : CabHandler {
        return _instance ;
    }
    
    func observeMessagesForDriver() {
        
        // RIDER REQUEST A RIDE
        DatabaseProvider.Instance.requestRef.observe(DataEventType.childAdded) {(snapshot : DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        if let riderName = data[Constants.NAME] as? String{
                            //inform the driver about the rider request
                            self.delegate?.acceptCab(name : riderName, lat: latitude, long: longitude);
                        }
                        
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.rider = name;
                    self.request_id = snapshot.key;
                }
            }
        }
        
      

        //RIDER CANCELED THE RIDE
        
        DatabaseProvider.Instance.requestRef.observe(DataEventType.childRemoved)
            {(snapshot : DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if self.cabAcceptedID != ""{
                        DatabaseProvider.Instance.requestAcceptedRef.child(self.cabAcceptedID).observeSingleEvent(of: .value, with: { (snapshot) in
                            print (data);
                            print(name);
                            if let data = snapshot.value as? NSDictionary {
                                print(data);
                                if let passenger = data[Constants.PASSENGER] as? String {
                                    //Check if the rider who has canceled the ride is our passenger
                                    print (passenger);
                                    if passenger ==  name{
                                        self.delegate?.riderHasCanceledCab();
                                    }
                                }
                            }
                        });
                    }
                }
            }
        }

        //RIDER UPDATING LOCATION
        DatabaseProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot : DataSnapshot) in
            
            if let data  = snapshot.value as? NSDictionary{
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double{
                        self.delegate?.updateRidersLocation(lat: lat, long: long) ;
                    }
                }
            }
        }
        
        
        
        //DRIVER ACCEPTS THE RIDE
        DatabaseProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) {(snapshot : DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as?  String {
                    if name == self.driver {
                        self.driver_id = snapshot.key;
                        print (self.driver_id);
                    }
                }
            }
        }
        
        //DRIVER CANCELED THE RIDE
        DatabaseProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) {(snapshot : DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as?  String {
                    if name == self.driver {
                        self.delegate?.driverHasCanceledCab(); 
                    }
                }
            }
        }
  
    }//observeMessagesForDriver
    
    func cabAccepted (latitude : Double , longitude : Double , req_accepted : String){
        //Reading the Ride Request database once
            DatabaseProvider.Instance.requestRef.child(request_id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let request_status = data[Constants.REQUEST_ACCEPTED] as? String {
                    //Check if the request has already been accepted by an other driver
                    if request_status == "true"{
                        self.delegate?.rideHasAlreadyBeenAccepted();
                    }else {
                        DatabaseProvider.Instance.requestRef.child(self.request_id).updateChildValues([Constants.REQUEST_ACCEPTED : "true"]);
                        
                        let mydata : Dictionary<String, Any>  = [Constants.NAME : self.driver, Constants.LATITUDE : latitude, Constants.LONGITUDE : longitude, Constants.REQUEST_ACCEPTED : req_accepted, Constants.PASSENGER : self.rider ] ;
                        let postRef = DatabaseProvider.Instance.requestAcceptedRef.childByAutoId();
                        //save the key of the CabAccepted child
                        self.cabAcceptedID = postRef.key;
                        
                        postRef.setValue(mydata);

                    
                        
                    }
                }
            }
            
            
        });
    }//cabAccepted
  
    func canceledCabForDriver() {
        DatabaseProvider.Instance.requestAcceptedRef.child(driver_id).removeValue();
        
    }//canceledCabForDriver
    
    func updateDriverLocation(lat : Double , long : Double) {
        print("UPDATING DRIVER LOCATION");
        print("UPDATING child :");
        print(driver_id);
        
        DatabaseProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LATITUDE : lat, Constants.LONGITUDE :long]);
    }
    
 
}//cabHandler























