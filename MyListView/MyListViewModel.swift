//
//  MyListViewModel.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/06/04.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import Foundation

class MyListViewModel{
   

    func getMyList(userId : String, handler : @escaping (Result<MyListModel,APIError>) ->() ){
        
        let url = "http://project.mintpass.kr:3000/list/\(userId)"
        
        guard let URL = URL(string: url) else {
            print("getMyList URL Error")
            handler(.failure(.GotError))
            return
        }
        
        URLSession.shared.dataTask(with: URL) { (data, _, _) in
            
            guard let data = data else {
                print("getMyList Data Error")
                handler(.failure(.GotError))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                
                let decodeResult = try decoder.decode(MyListModel.self, from: data)
                
                handler(.success(decodeResult))
                
                
            } catch  {
                print(error.localizedDescription)
                handler(.failure(.GotError))
            }
            
        }.resume()
        
        
    }
    
    func SendStarRating(sendMessage : SendSelectList, rating : Int, handler : @escaping (Result<Message,APIError>) -> () ){
           
           //post 방식으로 받을 웹서버 주소를 적어준다.
           guard let url = URL(string: "http://project.mintpass.kr:3000/rating") else {
               handler(.failure(.GotError))
               return
           }
           //request 형식으로 주소를 받아준다.
           var request = URLRequest(url: url)
           
           //전송방식을 POST로
           request.httpMethod = "PUT"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept-Type")
           
           //인코딩 해주는 것과 디코딩을 설정해주고
           let Encoder = JSONEncoder()
           let Decoder = JSONDecoder()
           
           //보내줄 정보를 Codable구조체로 만들어준다,
           Encoder.outputFormatting = .prettyPrinted
           
           do {
               //보내주기 위해서 data형식으로 인코딩 해준다,
            let jsonData = try Encoder.encode(StarRatingModel(id: sendMessage.id, user: sendMessage.userid, rating: rating))
               
               print(jsonData)
               //httpbody로 보내줄 준비 해주고
               request.httpBody = jsonData
               
               //그리고 나서 with url이 아니라 request로 데이터를 전송해주고
               URLSession.shared.dataTask(with: request) { (data, response, error) in
                   if let error = error{
                       print("Error took place URLSession in  SendStarRating \(error)")
                       handler(.failure(.GotError))
                       
                   }
                   
                   //오류없이 데이터를 받았다면 아래와 같이 다시 해독해주고 반응을 살핀다.
                   guard let data = data, let jsonString = String(data: jsonData, encoding: .utf8) else {
                        print("Error took place Data in SendStarRating")
                       handler(.failure(.GotError))
                       return
                       
                   }
                       print(data)
                       print(jsonString)
                       do {
                           //받았으면 decode 해주고 성공 메시지를 보내준다.
                           let myjson = try Decoder.decode(Message.self, from: data)
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
    
    
}
