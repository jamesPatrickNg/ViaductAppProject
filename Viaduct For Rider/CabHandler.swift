//
//  CabHandler.swift
//  Viaduct For Rider
//
//  Created by James-Patrick Ngoupayou on 31/08/2017.
//  Copyright © 2017 James-Patrick Ngoupayou. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CabController : class {
    func canCallCab (delegateCalled : Bool) ;
    func driverAcceptedRequest (requestAccepted : Bool ,driverName : String, latitude : Double, longitude :Double);
    func updateDriversLocation (lat : Double, long : Double);
}

class CabHandler  {
    private static let _instance =  CabHandler() ;
    
    weak var delegate : CabController?;
    
    var rider = "";
    var driver = "";
    var rider_id =  "" ;
    var Request_Accepted_by_Driver = "false"
     
    static var Instance : CabHandler {
        return _instance ;
    }
    
    func observeMessagesForRider (){
        // RIDER REQUESTED RIDE
        DatabaseProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot : DataSnapshot) in
            
            if let data  = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key;
                        self.delegate?.canCallCab(delegateCalled: true); 
                    }
                }
            }
        }
        
        //RIDER CANCELED RIDE
        DatabaseProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot : DataSnapshot) in
            
            if let data  = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.delegate?.canCallCab(delegateCalled: false);
                    }
                }
            }
        }
        
        //DRIVER ACCEPTED RIDE
        DatabaseProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot : DataSnapshot) in
            if let data  = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String {
                    if self.driver == "" {
                        self.driver=name;
                        if let lat = data[Constants.LATITUDE] as? Double{
                            if let long = data[Constants.LONGITUDE] as? Double{
                                self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver, latitude : lat, longitude : long);
                            }
                        }
                    }
                }
            }
        }
        
        //DRIVER CANCELED RIDE
        DatabaseProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot : DataSnapshot) in
            
            if let data  = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver  {
                        self.driver="";
                        if let lat = data[Constants.LATITUDE] as? Double{
                            if let long = data[Constants.LONGITUDE] as? Double{
                                self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: self.driver, latitude : lat, longitude : long);
                            }
                            
                        }
                    }
                }
            }
        }
        
        //DRIVER UPDATING LOCATION
        DatabaseProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot : DataSnapshot) in
            
            if let data  = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String {
                  if name == self.driver  {
                    print("NAME MATCH DRIVER")
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let long = data[Constants.LONGITUDE] as? Double{
                                print("updateDriversLocation")
                                self.delegate?.updateDriversLocation(lat: lat, long: long) ;
                             }
                        }
                    }
                }
            }
        }
        
    }//observeMessagesForRider
    
    func requestCab (latitude : Double, longitude : Double ){
        let data : Dictionary<String, Any> = [Constants.NAME : rider, Constants.LATITUDE: latitude, Constants.LONGITUDE : longitude, Constants.REQUEST_ACCEPTED : Request_Accepted_by_Driver ] ;
        
        DatabaseProvider.Instance.requestRef.childByAutoId().setValue(data);
    }//requestCab
    
    func cancelCab () {
        DatabaseProvider.Instance.requestRef.child(rider_id).removeValue();
    }//cancelCab
    
    func updateRiderLocation ( lat : Double, long : Double) {
        DatabaseProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE : long]);
    }//updateRiderLocation
    
}//class






















