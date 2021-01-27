//
//  Item.swift
//  ShoppingHelper
//
//  Created by njuios on 2020/12/31.
//

import Foundation
import UIKit
import SwiftSoup

class Item: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    var name: String
    var price: String
    var imageUrl: String
    var itemUrl: String
    var isSubscribed: Bool
//    var reviews = [Review]()
    var reviews = Set<Review>()
    //    var image: UIImage
    var itemId: String {
        if let start = itemUrl.lastIndex(of: "/"), let end = itemUrl.lastIndex(of: ".") {
            return String(itemUrl[itemUrl.index(after:start)..<end])
        }
        return ""
        //        return itemUrl.split(separator: "/")
    }
    init(name: String, price: String, imageUrl: String, itemUrl: String, isSubscribed: Bool) {
        self.name = name
        self.price = price
        self.imageUrl = imageUrl
        self.itemUrl = itemUrl
        self.isSubscribed = isSubscribed
    }
    func doWithCurrentPrice(operation:@escaping(Double?)->Void) {
        let url = "https://p.3.cn/prices/mgets?area=1&skuIds=J_" + itemId
        //        print(itemId)
        processUrl(url: url) {json in
            if let data = json.data(using: String.Encoding.utf8),
                let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String : Any]],
                let currentPrice = Double(dict[0]["p"] as! String){
                //                print(currentPrice)
                //                print(json)
                operation(currentPrice)
            }
            
            //            JSONDecoder().decode([Dictionary], from: json.data(using: .utf8))
            //            print("test")
            //            print(html)
        }
    }
    func doWithSentimentScore(operation:@escaping(Int)->Void) {
        let url = "https://club.jd.com/comment/productPageComments.action?productId=\(itemId)&score=0&sortType=5&page=0&pageSize=10&isShadowSku=0&rid=0&fold=1"
        let defaultScore = 5
        //        print(url)
        processUrl(url: url) { json in
//            print("test")
            if let data = json.data(using: String.Encoding.utf8),
                let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any],
                let comments = dict["comments"] as? [[String: Any]]{
                var sum = 0.0, num = 0
                for comment in comments {
                    if let content = comment["content"] as? String{
                        let score = analyzeSentiment(text: content)
                    
                        self.reviews.insert(Review(text: content, sentiment: Int(score)))
                        sum += score
                        num += 1
                    }
//                    print(comment["content"])
                }
                let score = num == 0 ? defaultScore : Int(sum / Double(num))
//                print(score)
//                print(num)
                operation(score)
            }
        }
    }
    override var hash: Int {
        return itemUrl.hashValue
    }
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Item else {
            return false
        }
        return self.itemUrl == other.itemUrl
    }
    //}
    //extension Item: Hashable {
    
    //    // Satisfy Hashable requirement
    //    override var hash: Int {
    //        //          get {
    //        //              return row.hashValue^col.hashValue
    //        //          }
    //        return itemUrl.hashValue
    //    }
    //    override func hash(into hasher: inout Hasher) {
    //
    
    
    // Satisfy Equatable requirement
    //    static func ==(lhs: Item, rhs: Item) -> Bool {
    //        return lhs.itemUrl == rhs.itemUrl
    //    }
    
    //}
    //
    //extension Item: NSCoding {
    struct PropertyKey {
        static let  name = "name"
        static let price = "price"
        static let  imageUrl = "imageUrl"
        static let  itemUrl = "itemUrl"
        static let  isSubscribed = "isSubscribed"
    }
    func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: PropertyKey.name)
        coder.encode(self.price, forKey: PropertyKey.price)
        coder.encode(self.imageUrl, forKey: PropertyKey.imageUrl)
        coder.encode(self.itemUrl, forKey: PropertyKey.itemUrl)
        coder.encode(self.isSubscribed, forKey: PropertyKey.isSubscribed)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String,
            let price = aDecoder.decodeObject(forKey: PropertyKey.price) as? String,
            let imageUrl = aDecoder.decodeObject(forKey: PropertyKey.imageUrl) as? String,
            let itemUrl = aDecoder.decodeObject(forKey: PropertyKey.itemUrl) as? String{
            let isSubscribed = aDecoder.decodeBool(forKey: PropertyKey.isSubscribed)
            self.init(name: name, price: price, imageUrl: imageUrl, itemUrl: itemUrl, isSubscribed: isSubscribed)
        } else {
            //        print(self)
            return nil
        }
    }
}

