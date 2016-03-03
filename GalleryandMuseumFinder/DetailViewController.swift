//
//  DetailViewController.swift
//  GalleryandMuseumFinder
//
//  Created by Taryn Parker on 2/16/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit
import GoogleMaps
import Google
import CoreLocation
import MapKit

class DetailViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var phoneTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var websiteTextView: UITextView!
    @IBOutlet weak var hoursTextView: UITextView!
    
    @IBOutlet weak var onTapSignOut: UIButton!
    
    @IBAction func onTapSignOut(sender: AnyObject) {
        //unauth() is the logout method for the current user.
        DataService.dataService.CURRENT_USER_REF.unauth()
        
        //remove the user's uid from storage
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
        
        //Head back to login
        let loginViewcontroller = self.storyboard!.instantiateViewControllerWithIdentifier("turnAroundBrightEyes")
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewcontroller
        print("method firing")
    
    }

    var detailArray = [Gallery]()
    
    var viaSegue: String!
    
    var photoRef: String!
    
    let session1 = NSURLSession.sharedSession()
    let session2 = NSURLSession.sharedSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.detailPull()
        
       
        
        if self.imageView.image != nil {
            self.photoPull()
        } else {
            
        }
        self.imageView.image = UIImage(named: "GalleryMe_Icon1024")
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            } .resume()
    }
    
    func detailPull () {
        
        let detailURL = String("https://maps.googleapis.com/maps/api/place/details/json?&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&placeid=\(self.viaSegue)")
        
        let url1 = NSURL(string: detailURL)
        
        let detailTask = session1.dataTaskWithURL(url1!) { (data , response, error ) -> Void in
            do {
                
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! Dictionary<String, AnyObject>
                let result = jsonDict["result"] as! Dictionary<String, AnyObject>
                
                
                
                if let photos = result["photos"] as? NSArray {
                    
                    for photoDict in photos {
                        self.photoRef = photoDict["photo_reference"] as? String
                        
                        self.photoPull()
                        
                    }
                }
                
                print("RESULT: \(result)")
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if let hoursDict = result["opening_hours"] as? Dictionary<String, AnyObject> {
                        print("HOURS: \(hoursDict)")
                        
                        let hoursArray = hoursDict["weekday_text"] as? NSArray
                        print("HOURS ARRAY: \(hoursArray)")
                        
                        
                        self.hoursTextView.text = (hoursArray!.componentsJoinedByString("\r\n"))
                        
                    }
                    self.nameLabel.text = result["name"] as? String
                    self.addressTextView.text = result["formatted_address"] as? String
                    self.addressTextView.editable = (false)
                    self.addressTextView.dataDetectorTypes = UIDataDetectorTypes.All
                    self.websiteTextView.text = result["website"] as? String
                    self.phoneTextView.text = result["formatted_phone_number"] as? String
                    self.phoneTextView.editable = (false)
                    self.phoneTextView.dataDetectorTypes = UIDataDetectorTypes.All
                    
                }
                
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
            }
            
        }
        
        detailTask.resume()
        
    }
    
    
    func photoPull () {
        let photoUrl = String("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&photoreference=\(self.photoRef)")
        
        if let url2 = NSURL(string: photoUrl) {
            
            getDataFromUrl(url2, completion: { (data, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageView.image = UIImage(data: data!)
                    
                    
                })
                
            })
            
        }
        
    }
    
}



