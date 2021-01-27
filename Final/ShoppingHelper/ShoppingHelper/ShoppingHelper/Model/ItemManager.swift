//
//  ItemManager.swift
//  ShoppingHelper
//
//  Created by njuios on 2020/12/31.
//

import Foundation
import SwiftSoup

class ItemManager {
    private(set) var items = [Item]()
    private(set) var subscribedItems = Set<Item>()
    private(set) var visitedItems = Set<Item>()
    
    private let baseUrl = "https://search.jd.com/Search?keyword="
    private var keyword = ""
    private var page = 1
    
    static var shared = ItemManager()
    
    private init() {
        let itemArr = loadSubscibedItems()
//        print(itemArr)
        if let itemArr = itemArr {
//            print(itemArr)
            subscribedItems = Set(itemArr)
        }
    }
    
    func updateItems(searchContent: String, completion: @escaping ()->Void) {
//        let url = "https://search.jd.com/Search?keyword="
        keyword = searchContent.addingPercentEncoding(withAllowedCharacters: CharacterSet.capitalizedLetters)!
        page = 1
        processItemsInUrl(url: baseUrl + keyword) {items in
            DispatchQueue.main.async {
                self.items = items
                completion()
            }
        }
//        keyword = searchContent
//        processUrl(url: url+searchContent) { html in
//            var items = [Item]()
//            do {
//                let doc: Document = try SwiftSoup.parse(html)
//                let elements: Elements = try doc.select(".gl-item")
//                for element in elements {
//                    let name = try element.select(".p-name").first()!.text()
//                    let price = try element.select(".p-price i").first()!.text()
//                    let imageUrl = try element.select(".p-img img").first()!.attr("data-lazy-img")
//                    let itemUrl = try element.select(".p-img a").first()!.attr("href")
//                    var item = Item(name: name, price: price, imageUrl: "https:" + imageUrl, itemUrl: "https:" + itemUrl, isSubscribed: false)
//                    item.isSubscribed = self.subscribedItems.contains(item)
//                    items.append(item)
//                }
//            } catch Exception.Error(_, let message) {
//                print(message)
//            } catch {
//                print("error")
//            }
//            DispatchQueue.main.async {
//                self.items = items
//                completion()
//            }
//        }
    }
    

    
    func loadMoreItems(completion: @escaping ()->Void) {
        page += 1
        processItemsInUrl(url: baseUrl + keyword + "&page=\(page)") {items in
            DispatchQueue.main.async {
                self.items += items
                completion()
            }
        }
    }
    
    private func processItemsInUrl(url: String, completion: @escaping ([Item])->Void) {
        processUrl(url: url) { html in
            var items = [Item]()
            do {
                let doc: Document = try SwiftSoup.parse(html)
                let elements: Elements = try doc.select(".gl-item")
                for element in elements {
                    let name = try element.select(".p-name").first()!.text()
                    let price = try element.select(".p-price i").first()!.text()
                    let imageUrl = try element.select(".p-img img").first()!.attr("data-lazy-img")
                    let itemUrl = try element.select(".p-img a").first()!.attr("href")
                    let item = Item(name: name, price: price, imageUrl: "https:" + imageUrl, itemUrl: "https:" + itemUrl, isSubscribed: false)
                    item.isSubscribed = self.subscribedItems.contains(item)
                    items.append(item)
                }
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
            completion(items)
        }
    }
    
    func toggleItemSubscribeState(index: Int) {
        let state = items[index].isSubscribed
//        items[index].doWithSentimentScore { score in
//            print(score)
//        }
        if state {
            items[index].isSubscribed = false
            subscribedItems.remove(items[index])
        } else {
            items[index].isSubscribed = true
            subscribedItems.insert(items[index])
        }
        saveSubscribedItems()
//        print(subscribedItems)
    }
    
    func addVisitedItem(item: Item) {
        visitedItems.insert(item)
    }
    
    func removeSubscribedItem(item: Item) {
        if let index = items.firstIndex(of: item) {
            items[index].isSubscribed = false
        }
        subscribedItems.remove(item)
        saveSubscribedItems()
    }
    
    private func saveSubscribedItems() {
        let isSuccess = NSKeyedArchiver.archiveRootObject(Array(subscribedItems), toFile: Item.ArchiveURL.path)
        if isSuccess {
            print("success save to file.")
        } else {
            print("unable to save to file.")
        }
    }
    
    private func loadSubscibedItems()->[Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item]
    }
}
