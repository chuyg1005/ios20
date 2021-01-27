//
//  ReviewViewController.swift
//  ShoppingHelper
//
//  Created by shiba on 2021/1/22.
//  Copyright © 2021 shiba. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sentimentLabel: UILabel!
    var reviewContent: String?
    var sentiment: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = reviewContent
        sentimentLabel.text = sentiment
        // Do any additional setup after loading the view.
    }
    
    func setReviewContent(review: String) {
        self.reviewContent = review
    }
    
    func setSentiment(sentiment: String) {
//        sentimentLabel.text = sentimentMapping[sentiment]
        self.sentiment = sentiment
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
