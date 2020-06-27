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

struct SendWeather : Codable {
    let weather : String
}

struct StoreInfo : Codable {
    
    var info : [MessageInfo]
    
}

struct MessageInfo : Codable {
    let id : Int
    let name : String
    let addr : String
    let img : String
    let tag : String
    
    let Thunderstorm : Int?
    let Drizzle : Int?
    let Rain : Int?
    let Snow : Int?
    let Atmosphere : Int?
    let Clear : Int?
    let Clouds : Int?
    
}
