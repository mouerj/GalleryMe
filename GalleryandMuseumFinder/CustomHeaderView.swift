//
//  CustomHeaderView.swift
//  GalleryandMuseumFinder
//
//  Created by Joseph Mouer on 2/24/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

import UIKit

class CustomHeaderView: UIView {

    @IBOutlet var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.preferredMaxLayoutWidth = label.bounds.width
    }



}
