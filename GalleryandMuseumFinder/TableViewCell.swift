//
//  TableViewCell.swift
//  
//
//  Created by Joseph Mouer on 2/25/16.
//
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var isOpen: UILabel!
    @IBOutlet weak var onTapSegue: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    
}
