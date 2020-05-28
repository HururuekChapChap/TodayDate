//
//  InfoDetailModels.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/28.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import Foundation

struct InfoDetail : Codable {
    
    let infodetail : [InfoArray]
}

struct InfoArray : Codable{
    let id : Int
    let tel : String
    let info : String
    let latitude : String
    let longitude : String
    let avg : Double
    let cnt : Int
}

struct ImageInfos : Codable{
    
    let imginfo : [ImageList]
}

struct ImageList : Codable {
    let id : Int
    let url : String
}
