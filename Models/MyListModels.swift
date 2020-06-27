//
//  MyListModels.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/06/04.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import Foundation

struct StarRatingModel : Codable{
    
    let id : Int
    let user : String
    let rating : Int

}

struct MyListModel : Codable {
    
    let listdetail : [ListDetail]
    
}

struct ListDetail :Codable {
    let id : Int
    let name : String
    let img : String
    let addr : String
    let tag : String
}
