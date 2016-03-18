//
//  ViewController.swift
//
//
//  Created by Joseph Mouer on 2/22/16.
//
//

import UIKit
import GoogleMaps
import Google
import CoreLocation
import MapKit

var tableView: UITableView!

class ViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, TableViewCellDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var tableView: GMtableView!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var MapView: GMSMapView!
    
    @IBOutlet var segmentControl: UISegmentedControl!
    
    var galleries = [NSDictionary]()
    
    var galleryArray = [Gallery]()
    
    var filtered = [Gallery]()
    
    var isSearchActive: Bool = false
    
    var refreshControl: UIRefreshControl!
    
    var latitude: Double!
    
    var mapTasks = MapTasks()
    
    var userLoc = String()
    
    var userLoc2 = String()
    
    var locationManager = CLLocationManager()
    
    var didFindMyLocation = false
    
    var locationMarker: GMSMarker!
    
    var markersArray: Array<GMSMarker> = []
    
    var placesClient: GMSPlacesClient?
    
    var currentPlaceID: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        //MARK: Map markers
        
        googleMapView.delegate = self
        
        googleMapView.settings.myLocationButton = true
        googleMapView.settings.compassButton = true
        googleMapView.myLocationEnabled = true
        
        googleMapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.rowHeight = 50
        
    }
    
    func refresh(sender:AnyObject) {
        self.isSearchActive = false
        self.data_request()
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered.removeAll()
        
        for galObj in galleryArray {
            if galObj.name.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                filtered.append(galObj)
            }
        }
        
        if searchText == "" {
            isSearchActive = false
            self.searchBar.endEditing(true)
        }
        else {
            isSearchActive = true
        }
        tableView.reloadData()
    }
    
    func onDiscosureTapped(placeID: String) {
        currentPlaceID = placeID
        performSegueWithIdentifier("toDetailVC", sender: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            googleMapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            googleMapView.settings.myLocationButton = true
            didFindMyLocation = true
        }
    }
    
    // MARK Change Map Type View
    
    @IBAction func MapView(sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.googleMapView.mapType = GoogleMaps.kGMSTypeNormal
        case 1:
            self.googleMapView.mapType = GoogleMaps.kGMSTypeHybrid
        default:
            self.googleMapView.mapType = GoogleMaps.kGMSTypeNormal
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            var userLocation:CLLocation = locations[0] as! CLLocation
            let long = userLocation.coordinate.longitude
            let lat = userLocation.coordinate.latitude
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks:[CLPlacemark]?, error: NSError?) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                if placemarks!.count > 0 {
                    let pm = placemarks![0] as! CLPlacemark
                    print(pm.locality)
                    self.userLoc = pm.locality!
                    self.data_request()
                    print("I'm in \(self.userLoc)")
                    
                    
                } else {
                    print("Problem with the data received from geocoder")
                }
                
            })
            print(lat, long)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let infoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil).first! as! CustomInfoWindow
        infoWindow.label.text = marker.title
        infoWindow.snippet.text = marker.snippet
        return infoWindow
    }
    
    func data_request() {
        
        let url1 = String("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(self.userLoc)&type=art_gallery&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg")
        let url2 = String("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(self.userLoc)&type=art_gallery&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&pagetoken=CqQDoAEAAHsw7tThV1V22yk57l00EASB3lYL9ANG0Zhi287TWYStsLLP2jMJjXIdsY41Pi3fTBvmrsoK1v_0-CfeHZkmGT5fHeHIEcTEj5kYsR1_uYqxooZVul1s7iFOzqzKMKz089JOpKNvedao71Oku_qBtaiJ25bmTF2laXsfAbrXH3sHi3CsdKdQiT8xo-bFgDiZlEGIBGlso3HM5YY5E2Wsg54uMYKU4_2RbD-xJVhl6JAobW8cn4mqe7UwAt8g3Iv0SxxUKuP8mOTcZXo60EfQ5snqXaNvWzy2yxcDbBtff6FTnjNuqYIOhVNg7SF0eyRZv2zcgbuU29WkyjZHUp5RqTyycZ-S6WyBCFv1GvcNy9TGf83VUzq6uZBxN6dEYOv35R9SIJ5NNNjetO97CnLNqJcXhC4JjLLRuwJUbGati2ZN5SKrIxGdeQSxkf7OETrQ81JQAkVzfD1Ap-Z7R3_lq7nNz_4vX9vXt-w9iIsGFQnXB0wUz_ODjtHz-_fcLl2ErgSj-sKdBZ5h2jLFlLcUscxjMhsLkgniJg6CmpWCCAx2EhAf0iT0qNwxOo02HZp0HED6GhQqM42r8FUYp8QIN4ynhH6SgG0dAA")
        let url3 = String("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(self.userLoc)&type=art_gallery&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&pagetoken=CvQB4QAAAN97q78lv5-0k4ymrAN634vgCQ4ZRpsi9Irq0GWm0Wsa5_jP2mnIPo_S1mMJHYTRuhBESfjgdrjfm43VnQhzXodXbeIfXTWb0Z1fYIL9cRIbGWMLHc-CI--fMDDbHuiOPK3M9W2drdb0lBrOWx2B0mgAaqNGc4H6PnGJ8wBYdp5ulc-6w5G1Obm1ai7pMECABc_AOVVSXZSqFHyPJ-oytt9kA54Z60NbuJyl86KBLSELhDMZYfPez6Z84zUZB-qmZyEws4t64i5SeH_WF4QszlRJsG86S9JnI-3tX-pBqyPD8DicdFYWbNFx_0OoRG6zARIQPNcliuomX5_JWRt5Ys1FNRoUEx8nzZJdYx7iY11qji1L8YOhkg4")
        let url4 = String("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(self.userLoc)&type=art_gallery&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&pagetoken=CvQB4QAAAJKqgaK9mciWANUddEgGhV0KhxJgvI03a2o8cuAUj_ftwjYbkEjn_woV79NpzMzQvhLZ7KcYO14M77oTUS5jZnHPse6ZQGvwig0cx9fKmhr7_sRqLzZO2zlMEtQgSwkuav7eAuPLbThj33xakabHgHMKFOaJlS1WSdTvEi1zTgJ2sZoO3GAwmjWjBrTIIWaL0kUPCpjwnAQlTEvg--lU2qNwdpeqwKAyIRy67NcVqhB_RguFTExbO7RKDgR39FT78Un5QySHFoM3eGt8zOK_COH6OUZW19mil70iXD9E1pARuxpwxpyCJE-cLHYqoVaGfBIQO7cdEarYOCT9f6YM6WBzQBoUPvkEpUtUHJEwlJsCML8DL7QFm1o")
        
        
        let urlOne = NSURL(string: url1)
        let urlTwo = NSURL(string: url2)
        let urlThree = NSURL(string: url3)
        let urlFour = NSURL(string: url4)
        
        let session1 = NSURLSession.sharedSession()
        let session2 = NSURLSession.sharedSession()
        let session3 = NSURLSession.sharedSession()
        let session4 = NSURLSession.sharedSession()
        
        let task = session1.dataTaskWithURL(urlOne!) { (data , response, error ) -> Void in
            do {
                print(error)
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary
                //       print(jsonDict)
                let galleries1 = jsonDict ["results"] as! [NSDictionary]
                for dictionary in galleries1 {
                    let galleryObject:Gallery = Gallery(galleryDictionary: dictionary)
                    if !self.galleryArray.contains(galleryObject) {
                        self.galleryArray.append(galleryObject)
                        
                    }
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    self.tableView.reloadData()
                }
            }
                
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
            }
        }
        task.resume()
        
        let task2 = session2.dataTaskWithURL(urlTwo!) { (data , response, error ) -> Void in
            do {
                print(error)
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary
                // print(jsonDict)
                let galleries2 = jsonDict ["results"] as! [NSDictionary]
                for dictionary in galleries2 {
                    let galleryObject:Gallery = Gallery(galleryDictionary: dictionary)
                    if !self.galleryArray.contains(galleryObject) {
                        self.galleryArray.append(galleryObject)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.tableView.reloadData()
                }
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
                
            }
        }
        task2.resume()
        
        let task3 = session3.dataTaskWithURL(urlThree!) { (data , response, error ) -> Void in
            do {
                print(error)
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary
                //       print(jsonDict)
                let galleries3 = jsonDict ["results"] as! [NSDictionary]
                for dictionary in galleries3 {
                    let galleryObject:Gallery = Gallery(galleryDictionary: dictionary)
                    if !self.galleryArray.contains(galleryObject) {
                        self.galleryArray.append(galleryObject)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.tableView.reloadData()
                }
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
                
            }
        }
        
        task3.resume()
        
        let task4 = session4.dataTaskWithURL(urlFour!) { (data , response, error ) -> Void in
            do {
                print(error)
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary
                //   print(jsonDict)
                let galleries4 = jsonDict ["results"] as! [NSDictionary]
                for dictionary in galleries4 {
                    let galleryObject:Gallery = Gallery(galleryDictionary: dictionary)
                    self.galleryArray.append(galleryObject)
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.tableView.reloadData()
                }
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
            }
        }
        task4.resume()
    }
    // MARK: TableView Implementation
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return (filtered.count)
        }
        else {
            return galleryArray.count
        }
    }
    
    func getSelectedGallery(indexPath: NSIndexPath) -> Gallery {
        if self.filtered.count > 0 {
            return self.filtered[indexPath.row]
        }
        return galleryArray[indexPath.row]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID") as! TableViewCell
        if isSearchActive {
            cell.contentView.userInteractionEnabled = true
            cell.cellName!.text = filtered[indexPath.row].name
            cell.addressLabel.text = filtered[indexPath.row].formattedAddress
            cell.onTapSegue.hidden = true
        }
        else  {
            cell.contentView.userInteractionEnabled = true
            cell.cellName!.text = galleryArray[indexPath.row].name
            cell.addressLabel.text = galleryArray[indexPath.row].formattedAddress
            cell.onTapSegue.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
        searchBar.text=""
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        cell.onTapSegue.hidden = false
        let gallery = getSelectedGallery(indexPath)
        let lat = gallery.latitude
        let lng = gallery.longitude
        let position = CLLocationCoordinate2DMake(lat, lng)
        let marker = GMSMarker(position: position)
        print(galleryArray[indexPath.row].placeID)
        marker.appearAnimation = GoogleMaps.kGMSMarkerAnimationPop
        marker.title = gallery.name
        marker.snippet = gallery.formattedAddress
        marker.map = self.googleMapView
        let target = CLLocationCoordinate2DMake(gallery.latitude, gallery.longitude)
        googleMapView.camera = GMSCameraPosition.cameraWithTarget(target, zoom: 16)
        self.currentPlaceID = (galleryArray[indexPath.row].placeID)
        
        if isSearchActive {
            currentPlaceID = (filtered[indexPath.row].placeID)
            cell.cellName!.text = filtered[indexPath.row].name
            cell.addressLabel.text = filtered[indexPath.row].formattedAddress
            cell.onTapSegue.hidden = false
        }
        
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TableViewCell {
            cell.onTapSegue.hidden = true
        }
    }
    
    @IBAction func onTapSegue(sender: UIButton) {
        let indexPath = tableView.indexPathForRowAtPoint(sender.center)
        self.currentPlaceID = (galleryArray[indexPath!.row].placeID)
        print("from prepare for onTapSegue\(self.currentPlaceID)")
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailVC" {
            let dvc = segue.destinationViewController as! DetailViewController
            dvc.detailArray = [Gallery]()
            dvc.viaSegue = self.currentPlaceID
            print("from prepare for segue\(self.currentPlaceID)")
            
        }
    }
    
    //CHANGE USER LOCATION
    
    @IBAction func onChangeLocationTapped(sender: UIBarButtonItem) {
        var inputTextField: UITextField!
        let changeLocPrompt = UIAlertController(title: "Enter New Location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        changeLocPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        changeLocPrompt.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            print("\(inputTextField?.text)")
            print("\(self.userLoc2)")
            self.userLoc2 = inputTextField.text!
            self.data_request2()
            self.tableView.reloadData()
        }))
        
        changeLocPrompt.addTextFieldWithConfigurationHandler ( { ( textField: UITextField!) in
            textField.placeholder = "City, State"
            textField.secureTextEntry = false
            inputTextField = textField
            
        })
        presentViewController(changeLocPrompt, animated: true, completion: nil)
        
        locationManager.startUpdatingLocation()
    }
    
    
    func data_request2() {
        
        let url1 = String("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(self.userLoc2)&type=art_gallery&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg")
        let url2 = String("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(self.userLoc2)&type=art_gallery&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&pagetoken=CqQDoAEAAHsw7tThV1V22yk57l00EASB3lYL9ANG0Zhi287TWYStsLLP2jMJjXIdsY41Pi3fTBvmrsoK1v_0-CfeHZkmGT5fHeHIEcTEj5kYsR1_uYqxooZVul1s7iFOzqzKMKz089JOpKNvedao71Oku_qBtaiJ25bmTF2laXsfAbrXH3sHi3CsdKdQiT8xo-bFgDiZlEGIBGlso3HM5YY5E2Wsg54uMYKU4_2RbD-xJVhl6JAobW8cn4mqe7UwAt8g3Iv0SxxUKuP8mOTcZXo60EfQ5snqXaNvWzy2yxcDbBtff6FTnjNuqYIOhVNg7SF0eyRZv2zcgbuU29WkyjZHUp5RqTyycZ-S6WyBCFv1GvcNy9TGf83VUzq6uZBxN6dEYOv35R9SIJ5NNNjetO97CnLNqJcXhC4JjLLRuwJUbGati2ZN5SKrIxGdeQSxkf7OETrQ81JQAkVzfD1Ap-Z7R3_lq7nNz_4vX9vXt-w9iIsGFQnXB0wUz_ODjtHz-_fcLl2ErgSj-sKdBZ5h2jLFlLcUscxjMhsLkgniJg6CmpWCCAx2EhAf0iT0qNwxOo02HZp0HED6GhQqM42r8FUYp8QIN4ynhH6SgG0dAA")
        let url3 = String("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(self.userLoc2)&type=art_gallery&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&pagetoken=CvQB4QAAAN97q78lv5-0k4ymrAN634vgCQ4ZRpsi9Irq0GWm0Wsa5_jP2mnIPo_S1mMJHYTRuhBESfjgdrjfm43VnQhzXodXbeIfXTWb0Z1fYIL9cRIbGWMLHc-CI--fMDDbHuiOPK3M9W2drdb0lBrOWx2B0mgAaqNGc4H6PnGJ8wBYdp5ulc-6w5G1Obm1ai7pMECABc_AOVVSXZSqFHyPJ-oytt9kA54Z60NbuJyl86KBLSELhDMZYfPez6Z84zUZB-qmZyEws4t64i5SeH_WF4QszlRJsG86S9JnI-3tX-pBqyPD8DicdFYWbNFx_0OoRG6zARIQPNcliuomX5_JWRt5Ys1FNRoUEx8nzZJdYx7iY11qji1L8YOhkg4")
        let url4 = String("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(self.userLoc2)&type=art_gallery&key=AIzaSyDNopD2lCPhs0z-Uap3f8EPUt9R3gGjGjg&pagetoken=CvQB4QAAAJKqgaK9mciWANUddEgGhV0KhxJgvI03a2o8cuAUj_ftwjYbkEjn_woV79NpzMzQvhLZ7KcYO14M77oTUS5jZnHPse6ZQGvwig0cx9fKmhr7_sRqLzZO2zlMEtQgSwkuav7eAuPLbThj33xakabHgHMKFOaJlS1WSdTvEi1zTgJ2sZoO3GAwmjWjBrTIIWaL0kUPCpjwnAQlTEvg--lU2qNwdpeqwKAyIRy67NcVqhB_RguFTExbO7RKDgR39FT78Un5QySHFoM3eGt8zOK_COH6OUZW19mil70iXD9E1pARuxpwxpyCJE-cLHYqoVaGfBIQO7cdEarYOCT9f6YM6WBzQBoUPvkEpUtUHJEwlJsCML8DL7QFm1o")
        
        
        let urlOne = NSURL(string: url1)
        let urlTwo = NSURL(string: url2)
        let urlThree = NSURL(string: url3)
        let urlFour = NSURL(string: url4)
        
        let session1 = NSURLSession.sharedSession()
        let session2 = NSURLSession.sharedSession()
        let session3 = NSURLSession.sharedSession()
        let session4 = NSURLSession.sharedSession()
        
        let task = session1.dataTaskWithURL(urlOne!) { (data , response, error ) -> Void in
            do {
                print(error)
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary
                      print(jsonDict)
                let galleries1 = jsonDict ["results"] as! [NSDictionary]
                for dictionary in galleries1 {
                    let galleryObject:Gallery = Gallery(galleryDictionary: dictionary)
                    if !self.galleryArray.contains(galleryObject) {
                        self.galleryArray.append(galleryObject)
                        
                    }
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    self.tableView.reloadData()
                }
            }
                
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
            }
        }
        task.resume()
        
        let task2 = session2.dataTaskWithURL(urlTwo!) { (data , response, error ) -> Void in
            do {
                print(error)
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary
                // print(jsonDict)
                let galleries2 = jsonDict ["results"] as! [NSDictionary]
                for dictionary in galleries2 {
                    let galleryObject:Gallery = Gallery(galleryDictionary: dictionary)
                    if !self.galleryArray.contains(galleryObject) {
                        self.galleryArray.append(galleryObject)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.tableView.reloadData()
                }
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
                
            }
        }
        task2.resume()
        
        let task3 = session3.dataTaskWithURL(urlThree!) { (data , response, error ) -> Void in
            do {
                print(error)
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary
                //       print(jsonDict)
                let galleries3 = jsonDict ["results"] as! [NSDictionary]
                for dictionary in galleries3 {
                    let galleryObject:Gallery = Gallery(galleryDictionary: dictionary)
                    if !self.galleryArray.contains(galleryObject) {
                        self.galleryArray.append(galleryObject)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.tableView.reloadData()
                }
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
                
            }
        }
        
        task3.resume()
        
        let task4 = session4.dataTaskWithURL(urlFour!) { (data , response, error ) -> Void in
            do {
                print(error)
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    as! NSDictionary
                //   print(jsonDict)
                let galleries4 = jsonDict ["results"] as! [NSDictionary]
                for dictionary in galleries4 {
                    let galleryObject:Gallery = Gallery(galleryDictionary: dictionary)
                    self.galleryArray.append(galleryObject)
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.tableView.reloadData()
                }
            }
            catch let error as NSError {
                print("jsonError: \(error.localizedDescription)")
            }
        }
        task4.resume()
    }
    
}
class GalleryNavigationController: UINavigationController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}







