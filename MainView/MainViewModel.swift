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
    //var WeatherInfo : OpenWeather?
    
    var ISGetWeather : Bool = false
    
    func setLocation(latitude : String?, longitude: String?){
        if let lati = latitude, let longi = longitude {
            self.latitude = lati
            self.longitude = longi
        }
    }
    
    
    //JSON API를 가져오는 방법
    //https://www.youtube.com/watch?v=tdxKIPpPDAI&t=1012s
    func GetWeatherInfo(handler : @escaping (Result<OpenWeather,APIError>) -> () ){
        
        guard let latitude = latitude , let longitude = longitude else {
            
            print("NO latitude and longitude")
            handler(.failure(.GotError))
            return}
        
        let url = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=b60295906c8a1dfb2ec7ed30423a5373"
        
        guard let weatehrUrl = URL(string: url) else {
            
            handler(.failure(.GotError))
            print("URL Failed")
            
            return}
        
        print("latitude :\(latitude) and longitude : \(longitude)")
        
        //url을 읽어야 하기 때문에 이렇게 해준다.
        URLSession.shared.dataTask(with: weatehrUrl) { (data, response, error) in
                   //data는 utf8으로 형성 되어 있다.
            guard let data = data else {
                 handler(.failure(.GotError))
                print("NO Data")
                return
                
            }
                   // JSONDecoder로 풀어준다.
                   let Decoder = JSONDecoder()
                   
                   do {
                       //decode 내부에는 가장 위에있는 최 상단에 있는 클래스를 넣어주고 self를 붙여줘서 자신임을 알려주고 from에서 가져올 데이터를 넣어준다.
                       let decodeResult = try Decoder.decode(OpenWeather.self, from: data)
                       //self.WeatherInfo = decodeResult
                        handler(.success(decodeResult))
                       print("지역 이름 : \(decodeResult.name)")
                       print("지역 온도 : \(decodeResult.main.temp)")
                       print("체감 온도 : \(decodeResult.main.feels_like)")
                       print("최고 온도 : \(decodeResult.main.temp_max)")
                       print("최저 온도 : \(decodeResult.main.temp_min)")
                       print("지역 습도 : \(decodeResult.main.humidity)")
                       print("날씨 상태 : \(decodeResult.weather[0].description)")
                       
                    self.ISGetWeather = true
                      
                   } catch {
                    handler(.failure(.GotError))
                       print("fail to Decode \(error.localizedDescription)")
                   }
                   
               }.resume()
        
    }
    
}


