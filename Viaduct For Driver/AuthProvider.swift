//
//  AuthProvider.swift
//  Viaduct For Driver
//
//  Created by James-Patrick Ngoupayou on 24/08/2017.
//  Copyright © 2017 James-Patrick Ngoupayou. All rights reserved.
//

import Foundation
import FirebaseAuth


/**
 This LoginHandler alias will inform the SignInViewController if we have any error
 */
typealias LoginHandler = (_ msg : String?) -> Void;

/**
 This structure contains a bunch of potential error messages to be displayed at the user in order to inform if any error occured
*/
struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid email adress, please provide a real email adress";
    static let WRONG_PASSWORD = "Invalid password, please enter the correct password";
    static let PROBLEM_CONNECTING = "Problem while connecting to database, please try later";
    static let USER_NOT_FOUND = "Please register first";
    static let EMAIL_ALREADY_IN_USE = "Please use another email";
    static let WEAK_PASSWORD = "Password should be at least 6 characters long";
}

class  AuthProvider {
    
    private static let _instance = AuthProvider() ;
    
    static var Instance:AuthProvider {
        return _instance;
    }
    
/**
      A function that allow us to log in the app.
*/
    func login(withEmail: String , password: String, loginHandler: LoginHandler?){
        Auth.auth().signIn(withEmail: withEmail, password: password, completion:{ (user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler);
            } else {
                loginHandler?(nil);
            }
        });
        
    
    }//login func
    
    
    /**
     A function that allow us to signUp the user by creating a new account in the Auth database .
     */
    func signUp(withEmail: String , password: String, loginHandler: LoginHandler?){
        
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler);
            }else {
                if user?.uid != nil {
                    
                    //store the user in the database
                    DatabaseProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password);
                    
                    //after creaing the user , we log him up in the app
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler);
                }
            }
        }
    }//signUp func
    
    /**
     A function that allow us to logOut the user.
     */
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut();
                return true;
            }catch {
                return false;
            }
        }
        return true ;
    }//logOut
    
    /**
     This function handles most potential case of errors that we are going to get during log in
     */
    private func handleErrors (err :NSError, loginHandler : LoginHandler?){
        
        if let errCode =  AuthErrorCode(rawValue: err.code) {
            switch errCode {
                case .wrongPassword :
                    loginHandler?(LoginErrorCode.WRONG_PASSWORD);
                    break;
                case .invalidEmail :
                    loginHandler?(LoginErrorCode.INVALID_EMAIL);
                    break;
                case .userNotFound :
                    loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                    break;
                case .weakPassword :
                    loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                    break;
                case .emailAlreadyInUse :
                    loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                    break;
                default :
                    loginHandler?(LoginErrorCode.PROBLEM_CONNECTING);
                    break;
            }
        }
    }
    
}//class

