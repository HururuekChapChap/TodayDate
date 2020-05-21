//
//  LaunchViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/02.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit
import CoreLocation

class LaunchViewController: UIViewController{
    
    @IBOutlet weak var NsTopToTitle: NSLayoutConstraint!
    //현재 위치 정보 가져오기
    //https://sanghuiiiiii.tistory.com/entry/SWIFT-현재-위치-주소-가져오기-미세먼지앱-1-Day?category=674800
    var location = MainViewModel.shared.location
    
    //status bar의 색깔을 검정으로 해줌
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NsTopToTitle.constant = view.bounds.height * 0.07
        
        //함수 내부에 CLLocationManager을 하면 안되고 따로 변수를 빼줘서 ViewDidLoad에 설정해줘야한다,
        location = CLLocationManager()
        //Delegate를 해줘야 특별한 설정이 가능하다. - CLLocationManagerDelegate 클래스 상속
        location?.delegate = self
        getLocation()
        // Do any additional setup after loading the view.
    }

    //화면 전환을 할때는 메모리에 올라오고 뷰가 설정이 됐을 때 해줘야한다.
//https://m.blog.naver.com/PostView.nhn?blogId=wlsdml1103&logNo=221026623860&proxyReferer=https:%2F%2Fwww.google.co.kr%2F
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.changeView()
        }

    }
    
    func changeView(){
        
        //UserDefault가 구조체일 경우에 데이터 형식으로 하여 Codable로 풀어줘야한다.
//https://www.hackingwithswift.com/example-code/system/how-to-load-and-save-a-struct-in-userdefaults-using-codable
        if let userNode =  UserDefaults.standard.object(forKey: "userNode") as? Data{
            let decoder = JSONDecoder()
            guard let userInfo = try? decoder.decode(PersonalInfo.self, from: userNode) else {return}
            
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? NavigationController else {return}
            
            vc.modalPresentationStyle = .fullScreen
            vc.InfoNode = userInfo
            
            self.present(vc, animated: true, completion: nil)
            
            
        }
        else{
            
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") else{return}
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }
        
    }
    
    

}

extension LaunchViewController : CLLocationManagerDelegate{
    
       func getLocation(){
                
                guard  let location = location else {return}
            
                location.desiredAccuracy = kCLLocationAccuracyBest
                
                let authorizationStatus = CLLocationManager.authorizationStatus()
    
                if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
                    location.requestWhenInUseAuthorization()
                } else {
                    location.startUpdatingLocation()
                    guard let coorlocation = location.location?.coordinate else {return}
                    print("First get Location passed")
                    MainViewModel.shared.setLocation(latitude: String(coorlocation.latitude), longitude: String(coorlocation.longitude))
                }
              
               }

}
