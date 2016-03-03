//
//  ResetViewController.swift
//  GalleryandMuseumFinder
//
//  Created by Danny Vasquez on 2/17/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit
import Firebase

class ResetViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayAlert()
    }
    

    @IBAction func onResetTapped(sender: AnyObject) {
        let email = emailTextField.text
        let ref = Firebase(url: "gallerynmuseumfinder.firebaseIO.com")
        ref.resetPasswordForUser(email) { (error) -> Void in
            if error != nil {
                //there was problem processing your request
                print(error?.localizedDescription)
                let alert = UIAlertController(title: "Error", message: "There was a problem when processing the request. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }else {
                //password reset successfully
                let alert = UIAlertController(title: "Your temporary password", message: "Has been sent to your email please login with the provided password", preferredStyle: UIAlertControllerStyle.Alert)
                
                //if user presses okay call the dismiss VC
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    
                })
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
                self.emailTextField.text = nil
            }
        }
    }
    
    
    @IBAction func onCancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayAlert() -> Void {
        let alert = UIAlertController(title: "Hello!", message: "You are expected to enter an email in order for us to process your request!", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    

}
