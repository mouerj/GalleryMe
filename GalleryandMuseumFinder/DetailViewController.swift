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
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var websiteTextView: UITextView!
    @IBOutlet weak var hoursTextView: UITextView!
    
    var detailArray = [Gallery]()
    
    var viaSegue: String!
    
    var photoRef: String!
    
    let session1 = NSURLSession.sharedSession()
    let session2 = NSURLSession.sharedSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.detailPull()
        
        print("making sure this works  \(self.viaSegue)")
        
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
                
                self.imageView.image = UIImage(named: "bob")
                
                if let photos = result["photos"] as? NSArray {
                    
                    for photoDict in photos {
                        self.photoRef = photoDict["photo_reference"] as? String
                        
                        self.photoPull()
                        print("PHOTO: \(self.photoRef)")
                        
                    }
                }
                
                print("RESULT: \(result)")
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    self.nameLabel.text = result["name"] as? String
                    self.addressLabel.text = result["formatted_address"] as? String
                    self.websiteTextView.text = result["website"] as? String
                    self.phoneNumber.text = result["formatted_phone_number"] as? String
                    self.hoursTextView.text = result["rating"] as? String
                    
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
        print("FROM PHOTO PULL \(self.photoRef)")
        
        if let url2 = NSURL(string: photoUrl) {
            
            getDataFromUrl(url2, completion: { (data, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageView.image = UIImage(data: data!)
                    
                })
                
            })
            
        }
        
    }
    
}
