//
//  APIViewModel.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/17.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import Foundation

struct SendSelectList : Codable{

let id : Int
let userid : String
    
}

class APIViewModel {
    
    let imageCache = MainViewModel.shared.NsCacheIMG
    
    var storeHash  :  [ String : [ MessageInfo ] ] = [:]
    
    func showAlert(title: String, text : String) ->UIAlertController {

            let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
            
            let Exit = UIAlertAction(title: "확인", style: .cancel)
                   
            alert.addAction(Exit)
            
        return alert
    }
    
    
    func getImageList(id : Int , handler : @escaping (Result<[ImageList],APIError>)->()){
        
        let url : String = "http://img.mintpass.kr/api/\(id)"
        
        guard let realUrl = URL(string: url) else {
            print("realURL Fail")
            handler(.failure(.GotError))
            return
        }
        URLSession.shared.dataTask(with: realUrl) { (data, _, _) in
            
            guard let data = data else {
                handler(.failure(.GotError))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                
                let decodeResult = try decoder.decode(ImageInfos.self, from: data)
                
                handler(.success(decodeResult.imginfo))
                
                
            } catch  {
                print(error.localizedDescription)
                handler(.failure(.GotError))
            }
            
        }.resume()
        
    }
    
    func getInfodetail(id : Int , handler : @escaping (Result<InfoArray,APIError>)->()){
        
        let url : String = "http://project.mintpass.kr:3000/location/\(id)"
        
        guard let realUrl = URL(string: url) else {
            print("realURL Fail")
            handler(.failure(.GotError))
            return
        }
        URLSession.shared.dataTask(with: realUrl) { (data, _, _) in
            
            guard let data = data else {
                handler(.failure(.GotError))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                
                let decodeResult = try decoder.decode(InfoDetail.self, from: data)
                
                handler(.success(decodeResult.infodetail[0]))
                
                
            } catch  {
                print(error.localizedDescription)
                handler(.failure(.GotError))
            }
            
        }.resume()
        
    }
    
    func getImageData(urlLink : String, handler : @escaping (Result<UIImage,APIError>) -> () ){
        
        guard let url = URL(string: urlLink) else {
            handler(.failure(.GotError))
            return
        }
        
        guard let ImageData = try? Data(contentsOf: url) , let Image = UIImage(data: ImageData)  else {
            handler(.failure(.GotError))
            return
        }
        
        imageCache.setObject(Image, forKey: urlLink as NSString)
        
        handler(.success(Image))
        
    }
    
    func SendStatus(sendMessage : SendSelectList,
                          commend : String , handler : @escaping (Result<Message,APIError>) -> () ){
           
           //post 방식으로 받을 웹서버 주소를 적어준다.
           guard let url = URL(string: "http://project.mintpass.kr:3000/list") else {
               handler(.failure(.GotError))
               return
           }
           //request 형식으로 주소를 받아준다.
           var request = URLRequest(url: url)
           
           //전송방식을 POST로
           request.httpMethod = "\(commend)"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept-Type")
           
           //인코딩 해주는 것과 디코딩을 설정해주고
           let Encoder = JSONEncoder()
           let Decoder = JSONDecoder()
           
           Encoder.outputFormatting = .prettyPrinted
           
           do {
               //보내주기 위해서 data형식으로 인코딩 해준다,
               let jsonData = try Encoder.encode(sendMessage)
               
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
    
    func SendUserInfoPost(sendMessage : String, handler : @escaping (Result<StoreInfo,APIError>) -> () ){
           
           //post 방식으로 받을 웹서버 주소를 적어준다.
           guard let url = URL(string: "http://project.mintpass.kr:3000/tag") else {
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
           let tagInfo = TagInfo(tag: sendMessage)
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
    
}

extension APIViewModel {
    
    func getTagList(storeInfo : StoreInfo, completeHandler : @escaping (Set<String>) -> ()){
        
        let list = storeInfo.info
        var set : Set<String> = []
        
        DispatchQueue.global().async {
            
            for element in list {
                       
                let tagString = element.tag.components(separatedBy: ", ")
                       
                    for tag in tagString{
                           
                        set.insert(tag)
                        self.storeHash[tag , default :[]].append(element)
                        
                       }
                   
                }
            
            completeHandler(set)
            
        }
        
        
    }
    
    func  classifyStore(_   tag  :  String) ->  [ MessageInfo ]  {
        return  storeHash[tag] ??  []
    }

    
}


