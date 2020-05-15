//
//  MainViewModel.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/02.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import Foundation
import CoreLocation

enum APIError : Error {
    case GotError
}

class MainViewModel  {
    
    static let shared = MainViewModel()
    
    var PersonalInfo: PersonalInfo?
    var location : CLLocationManager?
    
    var latitude : String?
    var longitude : String?
    
    var ISGetWeather : Bool = false
    
    func setLocation(latitude : String?, longitude: String?){
        if let lati = latitude, let longi = longitude {
            self.latitude = lati
            self.longitude = longi
        }
    }
    
}


