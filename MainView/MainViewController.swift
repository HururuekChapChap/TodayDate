//
//  MainViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/02.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMobileAds


struct ClothDetail{
    
     let clothesList : [String]
     let detail : String
}

//ca-app-pub-9919812549402833/7310063209
class MainViewController: UIViewController {

    @IBOutlet weak var nickname: UILabel!
    
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
    
    @IBOutlet weak var BannerView: GADBannerView!
    
    @IBOutlet var RandomView: UIView!
    @IBOutlet weak var RandomImage: UIImageView!
    @IBOutlet weak var RandomStoreName: UILabel!
    
    @IBOutlet weak var ClothCollectionView: UICollectionView!
    //스토어 프로퍼티를 정의 해주었다.
    var WeatherInfo : WeatherInfo? {
        
        //초기화가 처음으로 완료 될 때, 수행 해주도록 하였다.
        didSet{
            
            guard let weatherInfo = WeatherInfo else { return }
            
            SetClothDetail(tempuratore: Int(weatherInfo.openWeather.main.feels_like - 273 ))
            
            mainViewModel.weatherInfo = WeatherInfo
            
            let messageTosend = weatherModel.ClassifyWeather(weatherID: (weatherInfo.openWeather.weather[0].id))
          
            weatherModel.SendWeatherInfoPost(sendMessage: messageTosend!) { (result) in

                switch result{

                case .success(let apiResult):
                    self.RandomInfo = apiResult
                case .failure(_):
                    print("SendWeatherInfoPost Error")
                }

            }
            
            print("didSet 발동")
            DispatchQueue.main.async {
                self.CollectionViewItem.reloadData()
                self.updateUI()
            }
            
        }
        
    }
    
    
    var randNum : UInt32?
    var clothDetail : ClothDetail?{
        didSet{
            guard let clothDetail = clothDetail else {
                return
            }
            
            collectioinViewImgList = clothDetail.clothesList
            
            DispatchQueue.main.async {
                self.ClothCollectionView.reloadData()
                self.DetailLabel.text = clothDetail.detail
            }
        }
    }
    
    var RandomInfo : StoreInfo? {
        didSet{
            
          settingRandomDetailView()
      
        }
    }
    
    
    var collectioinViewImgList : [String] = []
    
    let weatherModel = WeatherModel()
    
    let mainViewModel = MainViewModel.shared
    
    
    
    override func viewDidLoad() {
           super.viewDidLoad()

        //네비게이션 백 버튼 지워줌
        self.navigationController?.navigationBar.topItem?.title = ""
        
        //클로저를 통해서 결과값이 반환이 된다면 그때 수행하도록 하였다.
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
        settingRandomView()
        
        let request = GADRequest()
        //원본 테스트 디바이스에서 실행하기 위해서는 이렇게 넣어줘야한다.
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["e409cab6defac3cbe73402227668d0c8"]
        
        BannerView.adUnitID = "ca-app-pub-9919812549402833/7310063209"
        //"ca-app-pub-3940256099942544/2934735716"
            
        BannerView.rootViewController = self
        BannerView.load(request)

        BannerView.delegate = self
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

extension MainViewController : GADBannerViewDelegate{
    
    
    /// Tells the delegate an ad request loaded an ad.
       func adViewDidReceiveAd(_ bannerView: GADBannerView) {
         print("adViewDidReceiveAd")
       }

       /// Tells the delegate an ad request failed.
       func adView(_ bannerView: GADBannerView,
           didFailToReceiveAdWithError error: GADRequestError) {
         print("Error: \(error.localizedDescription)")
       }
    
}

//UI랑 관련된 함수
extension MainViewController{
    
    func settingRandomDetailView(){
        
        if let randomInfo = RandomInfo {
            randNum = arc4random_uniform(UInt32(randomInfo.info.count))
                     //print("randNum : \(randNum) , count : \(randomInfo.info.count)")
            DispatchQueue.global().async {
                let image = self.weatherModel.getUIImage(url: randomInfo.info[Int(self.randNum!)].img )
                         
                DispatchQueue.main.async {
                    self.RandomImage.image = image
                    self.RandomStoreName.text = randomInfo.info[Int(self.randNum!)].name
                    }
            }
                     
        }
        
    }
    
    func settingRandomView(){
        
        RandomView.bounds.size.width = view.bounds.width - 30
        RandomView.layer.cornerRadius = 20
        RandomView.layer.borderWidth = 2
        RandomView.layer.borderColor = UIColor.systemYellow.cgColor
        
        RandomImage.layer.borderWidth = 1
        RandomImage.layer.cornerRadius = 15
        RandomImage.layer.borderColor = UIColor.black.cgColor
    }
    
    func settingView(){
        
               ClothDetailView.layer.cornerRadius = 15
               ClothDetailView.alpha = 0
               //DetailTitle.text = ""
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
            
        }
        
    }
       
    func updateUI(){
        
       if let weatherInfo = WeatherInfo{
    
            self.temperature.text = "\( Int(weatherInfo.openWeather.main.temp - 273) )°C"
            self.realTemperature.text = "\( Int(weatherInfo.openWeather.main.feels_like - 273))°C"
        self.minMaxTempertature.text = "\( Int(weatherInfo.openWeather.main.humidity))%"
            self.WeatherImg.image = weatherInfo.imageData

                }

       }
    
    func showAlert(title : String, text: String){
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
               
        let Exit = UIAlertAction(title: "확인", style: .destructive)
               
        alert.addAction(Exit)
               
        present(alert, animated: false, completion: nil)
        
    }
    
    func SetClothDetail(tempuratore : Int){
        
        var tempText : String
        var tempClothes : [String]
        
        if tempuratore < 4{
            
            tempText = "패딩, 두꺼운 코트를 입고 목도리와 기모제품으로 추위에 대비해주세요!"
            tempClothes = ["4-1.png","4-2.png","4-3.png","4-4.png","4-5.png","4-6.png"]
            
        }
        else if tempuratore < 9 {
            
            tempText = "코트와 가죽자켓으로 추위에 대비하고 히트텍, 니트, 레깅스를 입으면 딱!!"
            tempClothes = ["5-1.png","5-2.png","5-3.png","5-4.png","5-5.png"]
            
        }
        else if tempuratore < 12 {
            
            tempText = "자켓, 트렌치코트, 야상을 입고 안에는 니트, 청바지, 스타킹을 입어주면 될 거에요!"
            tempClothes = ["9-1.png","9-2.png","9-3.png","9-4.png","9-5.png","9-6.png"]
        }
        else if tempuratore < 17 {
            
            tempText = "본격적으로 쌀쌀해지는 날씨에 맞춰 자켓,가디건, 야상을 챙겨입으세요!"
            tempClothes = ["12-1.png","12-2.png","12-3.png","12-4.png","12-5.png"]
        }
        else if tempuratore < 20 {
            
            tempText = "이때부터는 얇은 니트와 맨투맨 가디건과 청바지를 입으면 좋습니다."
            tempClothes = ["17-1.png","17-2.png","17-3.png","17-4.png"]
        }
        else if tempuratore < 23 {
            
            tempText = "얇은 가디던, 긴팔, 면바지, 청바지로 코디해서 입으면 최고!!"
            tempClothes = ["20-1.png","20-2.png","20-3.png","20-4.png","20-5.png"]
        }
        else if tempuratore < 28 {
            
            tempText = "본격적으로 더워지니 반팔이나 얇은 셔츠와 함게 반바지나 면바지가 좋아요!"
            tempClothes = ["23-1.png","23-2.png","23-3.png","23-4.png"]
        }
        else {
            
            tempText = "정말 덥군요,,,, 민소매 또는 반팔, 반바지, 원피스를 추천할게요!"
            tempClothes = ["28-1.png","28-2.png","28-3.png","28-4.png"]
        }
        
        clothDetail = ClothDetail(clothesList: tempClothes, detail: tempText)
      
        
    }
    
    
}

//버튼을 담당하는 Extension
extension MainViewController{
    
    @IBAction func MylistBtn(_ sender: Any) {
        
    }
    
    @IBAction func RandomCloseBtn(_ sender: Any) {
        
        //투명도를 0으로 바꾸고 화면이 작아지는 것을 묘사해주기 위해서 transform의 scale을 작게 변경해준다
        //그리고 완료가 된 시점에 메인뷰에서 InfoView를 제거 해준다.
        UIView.animate(withDuration: 0.6, delay: 0, options: [], animations: {
            self.DimView.alpha = 0
            self.RandomView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }, completion: { (success) in
            self.RandomView.removeFromSuperview()
            self.settingRandomDetailView()
        })
        
      }
    
    @IBAction func RandomSelectBtn(_ sender: Any) {
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailInfoViewController") as? DetailInfoViewController else{return}
                      
            vc.storeInfo = RandomInfo?.info[Int(randNum!)]

            UINavigationController(rootViewController: vc).modalTransitionStyle = .crossDissolve
            self.navigationController?.pushViewController(vc, animated: true)
        
        
      }
      
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailViewControllerSegue"{
            
            if let vc = segue.destination as? DetailViewController, let item = sender as? String{
                
                vc.searchItem = item
                
            }
            
        }
        
        
    }
    
    //@@아무거나 버튼 생성해야함@@
    @IBAction func RandomBtn(_ sender: Any) {
        
        guard  let _ = WeatherInfo else {
            showAlert(title: "오류", text: "날씨 정보를 가져오는 중 입니다")
            return
        }
        
        guard let _ = RandomInfo else {
            showAlert(title: "오류", text: "서버에서 데이터를 받아오지 못했습니다.")
            return
        }
        
        //InfoView를 매인 뷰 위에 올려주고 중심에 가도록 해주었다.
        view.addSubview(RandomView)
        RandomView.center = view.center
        //그리고 화면이 등장하는것을 묘사해주기 위해서 기준 보다 작게 등장하다록 하였다.
        RandomView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        //불투명도인 alpha 값을 0.8로 해주어 InfoView가 눈에 더욱 잘 보이도록 해주었고 .identity로 원래 값으로 돌려주었다.
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
            self.DimView.alpha = 0.8
            self.RandomView.transform = .identity
            
        }, completion: nil)
        
    }
    
    @IBAction func EatBtn(_ sender: Any) {
        
        guard  let _ = WeatherInfo else {
            showAlert(title: "오류", text: "날씨 정보를 가져오는 중 입니다")
            return
        }
        
        performSegue(withIdentifier: "DetailViewControllerSegue", sender: "식사")
        
     }
  
     @IBAction func CafeBtn(_ sender: Any) {
        
        guard  let _ = WeatherInfo else {
                   showAlert(title: "오류", text: "날씨 정보를 가져오는 중 입니다")
                   return
               }
        
        performSegue(withIdentifier: "DetailViewControllerSegue", sender: "카페")
        
     }
     @IBAction func DrinkBtn(_ sender: Any) {
        
        guard  let _ = WeatherInfo else {
                   showAlert(title: "오류", text: "날씨 정보를 가져오는 중 입니다")
                   return
               }
        
        performSegue(withIdentifier: "DetailViewControllerSegue", sender: "술")
        
     }
    
    @IBAction func ActivityBtn(_ sender: Any) {
         
         guard  let _ = WeatherInfo else {
                    showAlert(title: "오류", text: "날씨 정보를 가져오는 중 입니다")
                    return
                }
         
         performSegue(withIdentifier: "DetailViewControllerSegue", sender: "실내활동")
         
      }
    
    @IBAction func OutSideActivityBtn(_ sender: Any) {
    
        guard  let _ = WeatherInfo else {
                          showAlert(title: "오류", text: "날씨 정보를 가져오는 중 입니다")
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
        //self.DetailTitle.text = ""
        //self.DetailLabel.text = ""
           }, completion: nil)
        
    }
    
    //버튼을 눌렀을 때, 자세한 설명이 나오도록 하였다.
    @IBAction func DetailBtn(_ sender: Any) {
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
            self.ClothDetailView.alpha = 0.8
           // self.DetailTitle.text = "추천 의상"
            //self.DetailLabel.text = "자세한 내용"
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
              
              return CGSize(width: 60, height: 60)
              
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

