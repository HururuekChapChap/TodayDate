//
//  WeatherModels.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/03.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import Foundation

struct OpenWeather : Codable{
    
    let weather : [Weather]
    let base : String
    let main : Main
    let name : String
    
}

struct Main : Codable{
    let temp : Double
    let feels_like : Double
    let temp_min : Double
    let temp_max : Double
    let humidity : Double
}

struct Weather : Codable{
    
    let description : String
    
}
