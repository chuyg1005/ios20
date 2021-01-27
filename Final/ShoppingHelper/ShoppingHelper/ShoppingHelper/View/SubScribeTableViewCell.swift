//
//  SubScribeTableViewCell.swift
//  ShoppingHelper
//
//  Created by shiba on 2020/12/31.
//  Copyright © 2020 shiba. All rights reserved.
//

import UIKit

// 收藏列表的单元格的视图
class SubScribeTableViewCell: UITableViewCell {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
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
