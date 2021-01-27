//
//  SearchTableViewCell.swift
//  ShoppingHelper
//
//  Created by njuios on 2020/12/31.
//

import UIKit

// 搜索列表的单元格的视图表示
class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var recommandLabel: UILabel!
    @IBOutlet weak var recommandButton: UIButton! // 推荐指数按钮，点击之后可以跳转到该商品的评论和其评分页面，参考SMDB
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
