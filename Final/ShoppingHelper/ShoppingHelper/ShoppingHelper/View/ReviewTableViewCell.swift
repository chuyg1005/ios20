//
//  ReviewTableViewCell.swift
//  ShoppingHelper
//
//  Created by shiba on 2021/1/21.
//  Copyright © 2021 shiba. All rights reserved.
//

import UIKit

fileprivate let sentimentMapping = [
    0: "😤",
    1: "😠",
    2: "😔",
    3: "😞",
    4: "😑",
    5: "🙂",
    6: "😊",
    7: "😁",
    8: "😍"
]

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var sentimentLabel: UILabel!
    
    @IBOutlet weak var reviewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setSentiment(sentiment: Int) {
        sentimentLabel.text = sentimentMapping[sentiment]
    }
}
