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
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var websiteTextView: UITextView!
   
    var detailArray = [Gallery]()
    
    var viaSegue: String!
    

    
    let photoURL = String("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRlAAAAs7_BywmwJ_Y5udZ77zewt8_APqZOu1rdqg7h5C_zI7gEO-hnFByVUuvBcAD1bhKiwa1IpCMACkmf037vztqnWOPBx0Ocrtdq8k3yk4RAg7UOPLj1PkQVy8sbSfUZ6UKeEO2hWefK1PHWgaSXX7_gfhIQDMYBM-V6E1wn6Yu-3Fe-bxoUKn6eM9SI8VatnSExK7hOwg9gCn8&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg")

    
    let session1 = NSURLSession.sharedSession()
    let session2 = NSURLSession.sharedSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.detailPull()
        
        print("making sure this works  \(self.viaSegue)")

        if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CmRdAAAAB84NH5OrUibk1rVmpSccMLOd706q-urUIjPNUput41lvdYIjPdg8cwFEojBT5sW4bViuM4bFBRAWimknEVoo-1J1wedx78o3a1UkHBDfuE5BTLypl9nK511CjtdBYOZLEhDM8YgNtBI9FGkva1oBxkP3GhSNvQm9uhkW1CrrEXYwuNr7YMhdag&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg") {
            
           
            getDataFromUrl(url, completion: { (data, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.image = UIImage(data: data!)
                    
                })
                
            })
            
        }
        
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
                print("RESULT: \(result)")
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.nameLabel.text = result["name"] as? String
                    self.addressLabel.text = result["formatted_address"] as? String
                    self.websiteTextView.text = result["website"] as? String
                    self.phoneNumber.text = result["formatted_phone_number"] as? String
                    self.openLabel.text = result["weekday_text"] as? String
                
                }
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
            }
            
        }
        
        detailTask.resume()
        
    }
   
    func NSTextCheckingTypesFromUIDataDetectorTypes(dataDetectorType: UIDataDetectorTypes) -> NSTextCheckingType {
        var textCheckingType: NSTextCheckingType = []
        
        if dataDetectorType.contains(.Address) {
            textCheckingType.insert(.Address)
        }
        
        if dataDetectorType.contains(.CalendarEvent) {
            textCheckingType.insert(.Date)
        }
        
        if dataDetectorType.contains(.Link) {
            textCheckingType.insert(.Link)
        }
        
        if dataDetectorType.contains(.PhoneNumber) {
            textCheckingType.insert(.PhoneNumber)
        }
        
        return textCheckingType
    }
    
    
}
