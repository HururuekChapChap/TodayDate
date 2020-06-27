//
//  ViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/04/29.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit
import KakaoOpenSDK

struct Temp : Codable{
    
    let user : String
 
}

struct Message : Codable{
    
    let message : String
    
}

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           layout()
         }
    
    private let loginButton: KOLoginButton = {
        let button = KOLoginButton()
        button.addTarget(self, action: #selector(touchUpLoginButton(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
      }()

    

    private func layout() {
           let guide = view.safeAreaLayoutGuide
           view.addSubview(loginButton)
           
           loginButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
           loginButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: guide.topAnchor, constant: self.view.bounds.height / 2).isActive = true
           loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
         }

}

//로그인 버튼 적용
extension ViewController{
    
    
    @objc private func touchUpLoginButton(_ sender: UIButton) {
       
      guard let session = KOSession.shared() else {
        return
      }
      
      if session.isOpen() {
        session.close()
      }
      
    session.open(completionHandler: { (error) -> Void in
          if error == nil {
              if session.isOpen() {
                  //accessToken
                  //print(session.token?.accessToken)
               
               KOSessionTask.userMeTask(completion: { (error, user) in
                           guard let user = user,
                            let nickname = user.account?.profile?.nickname, let id = user.id else {
                                
                                self.ViewAlert(message: "카카오톡 로그인 오류 입니다.")
                                
                                return }
                            
                            let encoder = JSONEncoder()
                            let userinfo = PersonalInfo(nickName: nickname, id: id)
                             print("success three \(nickname)")
                
                            self.SendUserInfoPost(InfoNode: userinfo) { (Result) in
                                     
                                     switch Result {
                                     
                                     case .success(_):
                                         print("전송 성공")
                                        
                                         //data형식으로 인코딩 해준다.
                                        let userNode = try? encoder.encode(userinfo)
                                         //그리고 그 정보를 UserDefaults에 저장해준다.
                                        UserDefaults.standard.set(userNode, forKey: "userNode")
                                                
                                         DispatchQueue.main.async {
                                            
                                            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? NavigationController else {return}
                                                                                             
                                                    vc.modalPresentationStyle = .fullScreen
                                                    vc.InfoNode = userinfo
                                                                                             
                                            self.present(vc, animated: true, completion: nil)
                                            
                                         }
                                        
                                        
                                     case .failure(_):
                                        
                                        DispatchQueue.main.async {
                                            self.ViewAlert(message: "오늘어때 서버 접속 오류 입니다.")
                                        }
                                        
                                         print("전송 실패")
                                     }
                                     
                                 }
                            
                         })
               
              } else {
                self.ViewAlert(message: "카카오톡 로그인 오류 입니다.")
                  print("Login failed")
              }
          } else {
            self.ViewAlert(message: "카카오톡 로그인 오류 입니다.")
              print("Login error : \(String(describing: error))")
          }
          if !session.isOpen() {
              if let error = error as NSError? {
                  switch error.code {
                  case Int(KOErrorCancelled.rawValue):
                      break
                  default:
                      //간편 로그인 취소
                       print("error last ")
                      print("error : \(error.description)")
                  }
              }
          }
      })
    }
    
}

extension ViewController{
    
    func ViewAlert(message : String){
        
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let Exit = UIAlertAction(title: "종료하기", style: .destructive) { (action) in
            exit(0)
        }
        
        alert.addAction(Exit)
        
         present(alert, animated: false, completion: nil)
        
    }
    
    func SendUserInfoPost(InfoNode : PersonalInfo ,handler : @escaping (Result<String,APIError>) -> () ){
        
        //post 방식으로 받을 웹서버 주소를 적어준다.
        guard let url = URL(string: "http://project.mintpass.kr:3000/login") else {
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
        let UserInfo = Temp(user: InfoNode.id)
        Encoder.outputFormatting = .prettyPrinted
        
        do {
            //보내주기 위해서 data형식으로 인코딩 해준다,
            let jsonData = try Encoder.encode(UserInfo)
            
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
                        print(myjson.message)
                        handler(.success(myjson.message))
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

