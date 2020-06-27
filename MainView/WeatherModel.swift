//
//  WeatherModel.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/12.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import Foundation

class WeatherModel{
    
    func getUIImage(url : String) ->UIImage?{
        
        guard let url = URL(string: url) else {
            print("Cannot Get Random UIImage URL")
            return nil}
        
        guard let imageData = try? Data(contentsOf: url) else {
            print("Cannot Get Random UIImage Data")
            return nil
        }
        
        return UIImage(data: imageData)
        
    }
    
    func ClassifyWeather(weatherID : Int)->String?{
        
        var sendInfo : String?
        
        if weatherID < 300 {
                sendInfo =  "Thunderstorm"
        }
        else if weatherID < 500 {
               sendInfo =  "Drizzle"
        }
        else if weatherID < 600 {
                sendInfo =  "Rain"
        }
        else if weatherID < 700 {
                sendInfo =  "Snow"
        }
        else if weatherID < 800 {
                sendInfo =  "Atmosphere"
        }
        else if weatherID == 800 {
                sendInfo = "Clear"
        }
        else if weatherID > 800 {
                sendInfo = "Clouds"
        }
        
        return sendInfo
    }
    
    func SendWeatherInfoPost(sendMessage : String, handler : @escaping (Result<StoreInfo,APIError>) -> () ){
        
        //post 방식으로 받을 웹서버 주소를 적어준다.
        guard let url = URL(string: "http://project.mintpass.kr:3000/random") else {
            handler(.failure(.GotError))
            return
        }
        //request 형식으로 주소를 받아준다.
        var request = URLRequest(url: url)
        
        //전송방식을 POST로
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept-Type")
        
        //인코딩 해주는 것과 디코딩을 설정해주고
        let Encoder = JSONEncoder()
        let Decoder = JSONDecoder()
        
        //보내줄 정보를 Codable구조체로 만들어준다,
        let tagInfo = SendWeather(weather:sendMessage)
        Encoder.outputFormatting = .prettyPrinted
        
        do {
            //보내주기 위해서 data형식으로 인코딩 해준다,
            let jsonData = try Encoder.encode(tagInfo)
            
            print(jsonData)
            //httpbody로 보내줄 준비 해주고
            request.httpBody = jsonData
            
            //그리고 나서 with url이 아니라 request로 데이터를 전송해주고
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error{
                    handler(.failure(.GotError))
                    print("Error took place \(error)")
                }
                
                //오류없이 데이터를 받았다면 아래와 같이 다시 해독해주고 반응을 살핀다.
                guard let data = data, let jsonString = String(data: jsonData, encoding: .utf8) else {
                    handler(.failure(.GotError))
                    return
                    
                }
                    print(data)
                    print(jsonString)
                    do {
                        //받았으면 decode 해주고 성공 메시지를 보내준다.
                        let myjson = try Decoder.decode(StoreInfo.self, from: data)
                        handler(.success(myjson))
                   } catch  {
                        handler(.failure(.GotError))
                        print("\(error.localizedDescription)")
                    }
                
            }.resume()
            
        } catch  {
            handler(.failure(.GotError))
        }
        
        
    }
    
    //JSON API를 가져오는 방법
    //https://www.youtube.com/watch?v=tdxKIPpPDAI&t=1012s
    func GetWeatherInfo(handler : @escaping (Result<WeatherInfo,APIError>) -> () ){
        
        guard let latitude = MainViewModel.shared.latitude , let longitude = MainViewModel.shared.longitude else {
            
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
                        
                                        print("지역 이름 : \(decodeResult.name)")
                                        print("지역 온도 : \(decodeResult.main.temp)")
                                        print("체감 온도 : \(decodeResult.main.feels_like)")
                                        print("최고 온도 : \(decodeResult.main.temp_max)")
                                        print("최저 온도 : \(decodeResult.main.temp_min)")
                                        print("지역 습도 : \(decodeResult.main.humidity)")
                                        print("날씨 상태 : \(decodeResult.weather[0].description)")
                                        print("날씨 아이콘 : \(decodeResult.weather[0].icon)")
                        
                    
                    if let url = URL(string: "http://openweathermap.org/img/wn/\(decodeResult.weather[0].icon)@2x.png"){
                        let imageData = try! Data(contentsOf: url)
                        let weatherImage = UIImage(data: imageData)
                        
                        let weatherInfo = WeatherInfo(imageData: weatherImage!, openWeather: decodeResult)
                        print("이미지 파일 가져옴")
                         handler(.success(weatherInfo))
                    }
                    else{
                        let weatherImage = UIImage(named: "Sun.png")
                        let weatherInfo = WeatherInfo(imageData: weatherImage!, openWeather: decodeResult)
                        print("이미지 파일 가져오지 못함")
                        handler(.success(weatherInfo))
                    }
                    
                      
                   } catch {
                    handler(.failure(.GotError))
                       print("fail to Decode \(error.localizedDescription)")
                   }
                   
               }.resume()
        
    }
    
    
    
}
