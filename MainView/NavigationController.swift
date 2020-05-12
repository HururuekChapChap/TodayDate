//
//  NavigationController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/02.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit
import CoreLocation

class NavigationController: UINavigationController , CLLocationManagerDelegate {

    var InfoNode: PersonalInfo?
    let mainViewModel = MainViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //지역 정보를 다시 받아오기 위해서는 이렇게 다시 location 값을 재설정 해줘야한다!!!
        mainViewModel.location = CLLocationManager()
        mainViewModel.location?.delegate = self
        UpdateLocation()
        changeView()
        // Do any additional setup after loading the view.
    }
    
    private func UpdateLocation(){
           
           guard let location = mainViewModel.location else {return}
        
            location.desiredAccuracy = kCLLocationAccuracyBest
                       
            let authorizationStatus = CLLocationManager.authorizationStatus()
           
            if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
                           location.requestWhenInUseAuthorization()
            } else {
               location.startUpdatingLocation()
               guard let coorlocation = location.location?.coordinate else {return}
               print("NavigationController UpdateLocation passed")
               mainViewModel.setLocation(latitude: String(coorlocation.latitude), longitude: String(coorlocation.longitude))
                       }

       }
    
    
    private func changeView(){
        
          if let InfoNode = InfoNode{
            
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else{return}
                
                 self.mainViewModel.PersonalInfo = InfoNode

                UINavigationController(rootViewController: vc).modalTransitionStyle = .crossDissolve
                self.navigationController?.pushViewController(vc, animated: true)
            
          }
      }

}


