//
//  Galleries.swift
//  GalleryandMuseumFinder
//
//  Created by Joseph Mouer on 2/21/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import Foundation


class Gallery: Equatable  {
    var name: String!
    var formattedAddress: String!
    var latitude: Double!
    var longitude: Double!
    var stringLat: String!
    var stringLong: String!
    var CLCoordinate = CLLocationCoordinate2D()
    var placeID: String!
    var detailFormattedAddress: String!
    var photoReference: String!
    
    
    init(galleryDictionary: NSDictionary) {
        let geometryDictionary = galleryDictionary["geometry"]
        let locationDictionary = geometryDictionary!["location"]
    
        name = galleryDictionary["name"] as! String
        formattedAddress = galleryDictionary["formatted_address"] as! String
        latitude = locationDictionary!!["lat"] as! Double
        longitude = locationDictionary!!["lng"] as! Double
        placeID = galleryDictionary["place_id"] as! String
        photoReference = galleryDictionary["photo_reference"] as! String
        
        CLCoordinate = CLLocationCoordinate2DMake(latitude, longitude)

    }
}

func ==(firstElement: Gallery, secondElement: Gallery) -> Bool {
    return firstElement.name == secondElement.name
}