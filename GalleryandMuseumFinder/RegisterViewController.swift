//
//  RegisterViewController.swift
//  GalleryandMuseumFinder
//
//  Created by Danny Vasquez on 2/17/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func onRegisterTapped(sender: AnyObject) {
        let userName = userNameTextField.text
        let userEmail = emailTextField.text
        let userPassword = passwordTextField.text
        let repeatPassword = repeatPasswordTextField.text
        
        
        //check if fields are empty
        if userName != "" && userEmail != "" && userPassword == repeatPassword {
            DataService.dataService.BASE_REF.createUser(userEmail, password: userPassword, withValueCompletionBlock: { (error, result) -> Void in
                if error != nil {
                    self.signupErrorAlert("Oops", message: "Having trouble creating your account. Try again.")
                }else {
                    DataService.dataService.BASE_REF.authUser(userEmail, password: userPassword, withCompletionBlock: { (error, authData) -> Void in
                        let user = ["password": authData.provider!, "email": userEmail!, "userName": userName!]
                        DataService.dataService.createNewAccount(authData.uid, user: user)
                    })
                    NSUserDefaults.standardUserDefaults().setValue(result["uid"], forKey: "uid")
                    
                    self.performSegueWithIdentifier("BackToLogin", sender: nil)
                }
            })
        }else {
            signupErrorAlert("Oops!", message: "Don't forget to enter your email, password, and username.")
        }
    }
    
    
    @IBAction func onCancelTapped(sender: AnyObject) {
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    func signupErrorAlert(title: String, message: String) {
        
        // Called upon signup error to let the user know signup didn't work.
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    
    


}
