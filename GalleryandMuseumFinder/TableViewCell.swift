//
//  TableViewCell.swift
//  
//
//  Created by Joseph Mouer on 2/25/16.
//
//

import UIKit

protocol TableViewCellDelegate {
    func onDiscosureTapped(placeID: String)
}

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var isOpen: UILabel!
    @IBOutlet weak var onTapSegue: UIButton!
    var placeID: String!
    var delegate: TableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onTapSegue(sender: UIButton) {
        self.delegate.onDiscosureTapped(placeID)
    }

    
}
