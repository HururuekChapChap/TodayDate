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
    @IBOutlet weak var KakaoToken: UILabel!
    
    @IBOutlet weak var WeatherImg: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var realTemperature: UILabel!
    @IBOutlet weak var minMaxTempertature: UILabel!
    
    //종료 버튼 - 버튼 스타일을 정의 해주기 위해서
    @IBOutlet weak var CloseBtn: UIButton!
    //Mark: InfoView
    @IBOutlet var InfoView: UIView!
    //Mark: DimView
    @IBOutlet weak var DimView: UIView!
    
    @IBOutlet weak var WeatherView: UIView!
    
    @IBOutlet weak var ClothView: UIView!
    
    @IBOutlet weak var ClothDetailView: UIView!
    @IBOutlet weak var DetailTitle: UILabel!
    @IBOutlet weak var DetailLabel: UILabel!
    
    @IBOutlet weak var CollectionViewItem: UICollectionView!
    
    
    //스토어 프로퍼티를 정의 해주었다.
    var WeatherInfo : WeatherInfo? {
        
        //초기화가 처음으로 완료 될 때, 수행 해주도록 하였다.
        didSet{
            collectioinViewImgList = clothesList
            print("didSet 발동")
            DispatchQueue.main.async {
                self.CollectionViewItem.reloadData()
                self.updateUI()
            }
            
        }
    }
    
    
    var collectioinViewImgList : [String] = []
    
    let clothesList : [String] = ["Sun.png","heart.png","Sun.png","heart.png","Sun.png","heart.png","Sun.png","heart.png"]
    
    let weatherModel = WeatherModel()
    
    let mainViewModel = MainViewModel.shared
    
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
//        //클로저를 통해서 결과값이 반환이 된다면 그때 수행하도록 하였다.
        weatherModel.GetWeatherInfo { (result) in

            switch result {
                case .failure(let error):
                    print(error)
            case .success(let weatherInfo):
                print("성공")
                self.WeatherInfo = weatherInfo
            }
        }
        
        settingView()
        
       }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInfo()
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

}

//UI랑 관련된 함수
extension MainViewController{
    
    func settingView(){
        
               ClothDetailView.layer.cornerRadius = 15
               ClothDetailView.alpha = 0
               DetailTitle.text = ""
               DetailLabel.text = ""
               
               ClothView.layer.cornerRadius = 15
               ClothView.layer.borderWidth = 2
               ClothView.layer.borderColor = UIColor.systemOrange.cgColor
               WeatherView.layer.cornerRadius = 15
               WeatherView.layer.borderWidth = 2
               WeatherView.layer.borderColor = UIColor.systemPink.cgColor
               //InfoView의 곡면을 20 정도 깍아주었다.
               InfoView.layer.cornerRadius = 20
               //경계선의 굵기와 색깔 그리고 둥글게 해주기 위해 곡면을 깍아주었다.
               CloseBtn.layer.borderWidth = 1
               CloseBtn.layer.borderColor = UIColor.white.cgColor
               CloseBtn.layer.cornerRadius = CloseBtn.bounds.width / 2
        
    }
    
    func updateInfo(){
        
        if let InfoNode = self.mainViewModel.PersonalInfo{
            
            self.nickname.text = "\(InfoNode.nickName)"
            self.KakaoToken.text = "\(InfoNode.id)"
            
        }
        
    }
       
    func updateUI(){
        
       if let weatherInfo = WeatherInfo{
    
            self.temperature.text = "\( Int(weatherInfo.openWeather.main.temp - 273) )°C"
            self.realTemperature.text = "\( Int(weatherInfo.openWeather.main.feels_like - 273))°C"
            self.minMaxTempertature.text = "\( Int(weatherInfo.openWeather.main.temp_max - 273))°C / \(Int(weatherInfo.openWeather.main.temp_min - 273))°C"
            self.WeatherImg.image = weatherInfo.imageData

                }

       }
    
    func showAlert(){
        
        let alert = UIAlertController(title: "오류", message: "날씨 정보를 가져오는 중 입니다", preferredStyle: UIAlertController.Style.alert)
               
        let Exit = UIAlertAction(title: "확인", style: .destructive)
               
        alert.addAction(Exit)
               
        present(alert, animated: false, completion: nil)
        
    }
    
}

//버튼을 담당하는 Extension
extension MainViewController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailViewControllerSegue"{
            
            if let vc = segue.destination as? DetailViewController, let item = sender as? String{
                
                vc.searchItem = item
                
            }
            
        }
        
    }
    
    //@@아무거나 버튼 생성해야함@@
    
    @IBAction func EatBtn(_ sender: Any) {
        
        guard  let _ = WeatherInfo else {
            showAlert()
            return
        }
        
        performSegue(withIdentifier: "DetailViewControllerSegue", sender: "식사")
        
     }
  
     @IBAction func CafeBtn(_ sender: Any) {
        
        guard  let _ = WeatherInfo else {
                   showAlert()
                   return
               }
        
        performSegue(withIdentifier: "DetailViewControllerSegue", sender: "카페")
        
     }
     @IBAction func DrinkBtn(_ sender: Any) {
        
        guard  let _ = WeatherInfo else {
                   showAlert()
                   return
               }
        
        performSegue(withIdentifier: "DetailViewControllerSegue", sender: "술")
        
     }
    
    @IBAction func ActivityBtn(_ sender: Any) {
         
         guard  let _ = WeatherInfo else {
                    showAlert()
                    return
                }
         
         performSegue(withIdentifier: "DetailViewControllerSegue", sender: "실내활동")
         
      }
    
    @IBAction func OutSideActivityBtn(_ sender: Any) {
    
        guard  let _ = WeatherInfo else {
                          showAlert()
                          return
                      }
               
               performSegue(withIdentifier: "DetailViewControllerSegue", sender: "야외활동")
    
    }
      
    
    @IBAction func Logout(_ sender: Any) {
           
        UserDefaults.standard.removeObject(forKey: "userNode")
    
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") else{return}
                  vc.modalPresentationStyle = .fullScreen
                  self.present(vc, animated: true, completion: nil)
       }
    
    //화면을 눌렀을 때, 자세한 내용의 설명이 사라지도록 했다.
    @IBAction func TapBtn(_ sender: Any) {
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
        self.ClothDetailView.alpha = 0
        self.DetailTitle.text = ""
        self.DetailLabel.text = ""
           }, completion: nil)
        
    }
    
    //버튼을 눌렀을 때, 자세한 설명이 나오도록 하였다.
    @IBAction func DetailBtn(_ sender: Any) {
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
            self.ClothDetailView.alpha = 0.8
            self.DetailTitle.text = "추천 의상"
            self.DetailLabel.text = "자세한 내용"
               }, completion: nil)
        
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
    
}

//collectionView
extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectioinViewImgList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothCell", for: indexPath) as? ClothCell else {return UICollectionViewCell()}
        
        cell.UpdateImg(name: collectioinViewImgList[indexPath.item])
        
        return cell
    }
   
    //이미지의 크기를 80 * 80 으로 해줬고 storyBoard에서 SizeExpecter - Estimate Size를 None으로 해준더. (Horizontal CollectionView일 경우)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
              
              return CGSize(width: 80, height: 80)
              
          }
  
    
    
}


//이미지 Horizontal collectionView의 Cell
class ClothCell : UICollectionViewCell {
    
    @IBOutlet weak var clothImg: UIImageView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           
       }
       
    override func prepareForReuse() {
           super.prepareForReuse()
           
       }
    
    func reset() {
           // TODO: reset로직 구현
          clothImg = nil
       }
    
    func UpdateImg(name : String){
        clothImg.image = UIImage(named: name)
    }
    
}

