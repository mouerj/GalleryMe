//
//  DetailViewController.swift
//  GalleryandMuseumFinder
//
//  Created by Joseph Mouer on 2/16/16.
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
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var viaSegueLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var detailArray = [Gallery]()
    
    var viaSegue: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailPull()
        print("hey.. is this working?\(viaSegue)")
    }
    
    func detailPull () {
     
        
        let detailURL = String("https://maps.googleapis.com/maps/api/place/details/json?&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&placeid=\(self.viaSegue)")
    
        let session1 = NSURLSession.sharedSession()
        
        let url1 = NSURL(string: detailURL)

        
        let task1 = session1.dataTaskWithURL(url1!) { (data , response, error ) -> Void in
            do {
                
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! Dictionary<String, AnyObject>
                let result = jsonDict["result"] as! Dictionary<String, AnyObject>
               //  print("RESULT: \(result)")
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.nameLabel.text = result["name"] as? String
                    self.addressLabel.text = result["formatted_address"] as? String
                    self.websiteLabel.text = result["website"] as? String
                    self.phoneNumber.text = result["formatted_phone_number"] as? String
                    self.openLabel.text = result["opening_hours"] as? String
                    
                }
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
            }
            
        }
        
        task1.resume()
        
        
    }
}




