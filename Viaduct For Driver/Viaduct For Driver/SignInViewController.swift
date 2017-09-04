//
//  SignInViewController.swift
//  Viaduct For Driver
//
//  Created by James-Patrick Ngoupayou on 24/08/2017.
//  Copyright © 2017 James-Patrick Ngoupayou. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    private let   DRIVER_SEGUE = "DriverViewController";
    
 
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logIn(_ sender: Any) {
       //Here we handle the log in action if emailTextFiel and passwordTextField are not empty.
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            //Here we handle the log in by calling AuthProvider function
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                //Here we inform the user about what is going on
                if message != nil{
                    self.alertTheUser(title: "Problem with Authentication", message: message!)
                }else{
                    CabHandler.Instance.driver = self.emailTextField.text! ;
                    //self.emailTextField!.text = "" ;
                    //self.passwordTextField!.text = "" ;
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil)
                }
            });
        }//if
    }
    
    @IBAction func signUp(_ sender: Any) {
        if emailTextField.text! != "" && passwordTextField.text != "" {
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem with creating a new user", message: message!);
                }else {
                    CabHandler.Instance.driver = self.emailTextField.text! ;
                    //self.emailTextField!.text = "" ;
                    //self.passwordTextField!.text = "" ;
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil)
                }
            });
            
        }else{
            alertTheUser(title: "Email and password are requiered", message: "Please enter email and password in the text fields")
        }
    }//signUp
  
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

}//class



















