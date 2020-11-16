//
//  ShoppingItem.swift
//  ShoppingTracker
//
//  Created by shiba on 2020/11/12.
//  Copyright © 2020 shiba. All rights reserved.
//

import UIKit

class ShoppingItem: NSObject, NSCoding {
    struct PropertyKey {
        static let name = "name"
        static let image = "image"
        static let desc = "desc"
    }
    
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("shoppingItems")
    
    var name: String
    var image: UIImage?
    var desc: String
    
    init?(name: String, image: UIImage?, desc: String) {
        if name.isEmpty || desc.isEmpty {
            return nil
        }
        self.name = name
        self.image = image
        self.desc = desc
    }
    
    // 序列化
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(image, forKey: PropertyKey.image)
        coder.encode(desc, forKey: PropertyKey.desc)
    }
    
    // 反序列化
    required convenience init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else {
            return nil
        }
        let image = coder.decodeObject(forKey: PropertyKey.image) as? UIImage
        guard let desc = coder.decodeObject(forKey: PropertyKey.desc) as? String else {
            return nil
        }
        self.init(name: name, image: image, desc: desc)
    }
    
}
