//
//  Review.swift
//  ShoppingHelper
//
//  Created by shiba on 2021/1/21.
//  Copyright © 2021 shiba. All rights reserved.
//

import Foundation

struct Review {
    var text: String
    var sentiment: Int?
}

extension Review: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
    
    static func ==(lhs: Review, rhs: Review) -> Bool {
        return lhs.text == rhs.text
    }
}
