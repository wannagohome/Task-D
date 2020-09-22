//
//  Room.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/22.
//  Copyright © 2020 Pete. All rights reserved.
//

import Foundation


struct RoomList: Codable {
    var average: [Average]?
    var rooms: [Room]?
}

struct Average: Codable {
    var monthPrice, name, yearPrice: String?
}

struct Room: Codable {
    var desc: String?
    var isCheck: Bool?
    var priceTitle: String?
    var roomType, sellingType: Int?
    var hashTags: [String]?
    var imgURL: String?
    var price: Int {
        get {
            var result = 0
            var str = self.priceTitle
            
            if str?.contains("억") ?? false {
                result += Int((str?.components(separatedBy: "억")[0])!)! * 10000
                str = str?.components(separatedBy: "억")[1]
            }
            
            if str?.contains("천") ?? false {
                result += Int((str?.components(separatedBy: "천")[0])!)! * 1000
                str = str?.components(separatedBy: "천")[1]
            }
            
            if str?.contains("만") ?? false {
                result += Int((str?.components(separatedBy: "만")[0])!)!
            }
            return result
        }
    }

    enum CodingKeys: String, CodingKey {
        case desc
        case isCheck = "is_check"
        case priceTitle = "price_title"
        case roomType = "room_type"
        case sellingType = "selling_type"
        case hashTags = "hash_tags"
        case imgURL = "img_url"
    }
}
