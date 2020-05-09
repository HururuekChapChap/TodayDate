//
//  ViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/04/29.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit
import KakaoOpenSDK

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
           loginButton.bottomAnchor.constraint(equalTo: guide.topAnchor, constant: 100).isActive = true
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
                            let nickname = user.nickname, let id = user.id else { return }
                            
                           print("success three \(nickname)")
                
                            let encoder = JSONEncoder()
                            let userinfo = PersonalInfo(nickName: nickname, id: id)
                            let userNode = try? encoder.encode(userinfo)
                            UserDefaults.standard.set(userNode, forKey: "userNode")
                        
                            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? NavigationController else {return}
                            
                            vc.modalPresentationStyle = .fullScreen
                            vc.InfoNode = userinfo
                            
                            self.present(vc, animated: true, completion: nil)
                
                         })
               
              } else {
                  print("Login failed")
              }
          } else {
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

