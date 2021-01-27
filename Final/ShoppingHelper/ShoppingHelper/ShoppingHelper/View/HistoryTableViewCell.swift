//
//  HistoryTableViewCell.swift
//  ShoppingHelper
//
//  Created by shiba on 2021/1/11.
//  Copyright © 2021 shiba. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

//    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
          var detailLink: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
