//
//  ShoppingItemTableViewCell.swift
//  ShoppingTracker
//
//  Created by shiba on 2020/11/12.
//  Copyright © 2020 shiba. All rights reserved.
//

import UIKit

class ShoppingItemTableViewCell: UITableViewCell {
    //MARK: properties
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
