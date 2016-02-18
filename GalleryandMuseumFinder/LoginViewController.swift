//
//  LoginViewController.swift
//  GalleryandMuseumFinder
//
//  Created by Danny Vasquez on 2/17/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: Firebase!
    var authHelper: TwitterAuthHelper!
    var accounts: [ACAccount]!
    var account = ACAccount()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        ref = Firebase(url: "gallerynmuseumfinder.firebaseIO.com")
        authHelper = TwitterAuthHelper(firebaseRef: ref, apiKey: "tpRrduRnsnj5Ehk3BR0z4lGAS")
    }
    
    
    

    @IBAction func onLoginTapped(sender: AnyObject) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if email != "" && password != "" {
            DataService.dataService.BASE_REF.authUser(email, password: password, withCompletionBlock: { (error, authData) -> Void in
                if error != nil {
                    print(error)
                    self.loginErrorAlert("Oops", message: "Check your username and password")
                }else {
                    // be sure the correct uid is stored
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                    //enter the app 
                    self.performSegueWithIdentifier("EnterApp", sender: nil)
                }
            })
        }else {
            //there was a problem
            loginErrorAlert("Oops", message: "Don't forget to enter your email and password")
        }
    }

    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //if we have the uid stored, the user is already  logged in - no need to sign in
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && DataService.dataService.CURRENT_USER_REF.authData != nil {
            //proceed to enter the app
            self.performSegueWithIdentifier("EnterApp", sender: nil)
        }
    }
    
    
    @IBAction func onTwitterTapped(sender: AnyObject) {
        self.authWithTwitter()
    }
    
    func loginErrorAlert(title: String, message: String) {
        // called upon login error to let the user know login didn't work
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}