//
//  MainViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/02.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {

   @IBOutlet weak var nickname: UILabel!
       
    @IBOutlet weak var temperature: UILabel!
    
    //종료 버튼 - 버튼 스타일을 정의 해주기 위해서
    @IBOutlet weak var CloseBtn: UIButton!
    //Mark: InfoView
    @IBOutlet var InfoView: UIView!
    //Mark: DimView
    @IBOutlet weak var DimView: UIView!
    //스토어 프로퍼티를 정의 해주었다.
    var WeatherInfo : OpenWeather? {
        
        //초기화가 처음으로 완료 될 때, 수행 해주도록 하였다.
        didSet{
            
            DispatchQueue.main.async {
                self.updateUI()
            }
            
        }
    }
    
    //X 버튼을 눌렀을 경우
    @IBAction func CloseBtnAct(_ sender: Any) {
        
        //투명도를 0으로 바꾸고 화면이 작아지는 것을 묘사해주기 위해서 transform의 scale을 작게 변경해준다
        //그리고 완료가 된 시점에 메인뷰에서 InfoView를 제거 해준다.
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.DimView.alpha = 0
            self.InfoView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }, completion: { (success) in
            self.InfoView.removeFromSuperview()
        })
        
    }
    //사용자 버튼을 눌렀을 경우
    @IBAction func UserInfoBtn(_ sender: Any) {
        
        //InfoView를 매인 뷰 위에 올려주고 중심에 가도록 해주었다.
        view.addSubview(InfoView)
        InfoView.center = view.center
        //그리고 화면이 등장하는것을 묘사해주기 위해서 기준 보다 작게 등장하다록 하였다.
        InfoView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        //불투명도인 alpha 값을 0.8로 해주어 InfoView가 눈에 더욱 잘 보이도록 해주었고 .identity로 원래 값으로 돌려주었다.
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
            self.DimView.alpha = 0.8
            self.InfoView.transform = .identity
        }, completion: nil)
        
    }
    
    let mainViewModel = MainViewModel.shared
    
       override func viewDidLoad() {
           super.viewDidLoad()
        
        //클로저를 통해서 결과값이 반환이 된다면 그때 수행하도록 하였다.
        mainViewModel.GetWeatherInfo { (result) in
            
            switch result {
                case .failure(let error):
                    print(error)
            case .success(let weatherInfo):
                self.WeatherInfo = weatherInfo
            }
        }
        //InfoView의 곡면을 20 정도 깍아주었다.
        InfoView.layer.cornerRadius = 20
        //경계선의 굵기와 색깔 그리고 둥글게 해주기 위해 곡면을 깍아주었다.
        CloseBtn.layer.borderWidth = 2
        CloseBtn.layer.borderColor = UIColor.gray.cgColor
        CloseBtn.layer.cornerRadius = CloseBtn.bounds.width / 2
        
       }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
        
    //네비게이션 관련 설정
       //https://zeddios.tistory.com/574
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.navigationController?.isNavigationBarHidden = true
       }
       
        override func viewWillDisappear(_ animated: Bool) {
               super.viewWillDisappear(animated)
               self.navigationController?.isNavigationBarHidden = false
           }


       @IBAction func Logout(_ sender: Any) {
           
           UserDefaults.standard.removeObject(forKey: "userNode")
           nickname.text = "로그인 해주세요"
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") else{return}
                  vc.modalPresentationStyle = .fullScreen
                  self.present(vc, animated: true, completion: nil)
       }
       
       private func updateUI(){
        
         if let InfoNode = self.mainViewModel.PersonalInfo, let weatherInfo = WeatherInfo{
                        self.nickname.text = InfoNode.nickName
                        self.temperature.text = String(weatherInfo.main.temp)
        
                              }

       }

}
