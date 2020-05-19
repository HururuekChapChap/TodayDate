//
//  StoreInfo.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/17.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import Foundation

struct TagInfo : Codable {
    
    let tag : String
    
}

struct StoreInfo : Codable {
    
    let info : [MessageInfo]
    
}

struct MessageInfo : Codable {
    let id : Int
    let name : String
    let addr : String
    let tag : String
}
