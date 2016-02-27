//
//  IntroViewController.swift
//  GalleryandMuseumFinder
//
//  Created by Taryn Parker on 2/25/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit
import Firebase



class IntroViewController: UIViewController {

    @IBOutlet weak var newAccountButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var letsGoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && DataService.dataService.CURRENT_USER_REF.authData != nil {
            newAccountButton.hidden = true
            loginButton.hidden = true
        
        } else {
            
            letsGoButton.hidden = true
        }

    }

}



