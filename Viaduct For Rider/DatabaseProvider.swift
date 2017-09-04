//
//  DatabaseProvider.swift
//  Viaduct For Rider
//
//  Created by James-Patrick Ngoupayou on 25/08/2017.
//  Copyright © 2017 James-Patrick Ngoupayou. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DatabaseProvider {
    private static let _instance  = DatabaseProvider();
    
    static var Instance: DatabaseProvider {
        return _instance ;
    }

    //Reference to our database
    var dbRef : DatabaseReference {
        return Database.database().reference();
    }
    
    //Reference to our rider child
    var ridersRef : DatabaseReference {
        return dbRef.child(Constants.RIDERS);
    }
    
    //request Ref
    var requestRef : DatabaseReference{
        return dbRef.child(Constants.CAB_REQUEST);
    }
    
    //request accepted
    var requestAcceptedRef : DatabaseReference {
        return dbRef.child(Constants.CAB_ACCEPTED);
    }
    
    func saveUser(withID : String, email : String , password : String){
        let data : Dictionary<String, Any> = [Constants.EMAIL : email , Constants.PASSWORD : password , Constants.isRider : true] ;
        
        ridersRef.child(withID).child(Constants.DATA).setValue(data);
        
    }

}//class






