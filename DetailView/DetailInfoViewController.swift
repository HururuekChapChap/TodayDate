//
//  DetailInfoViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/26.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit
import MapKit

class DetailInfoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var StoreName: UILabel!
    @IBOutlet weak var StoreAddr: UILabel!
    @IBOutlet weak var StorePhone: UILabel!
    @IBOutlet weak var StoreRate: UILabel!
    @IBOutlet weak var StoreComment: UILabel!
    
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var TagStackView: UIStackView!
    
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var FrameView: UIView!
    @IBOutlet weak var FrameWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var PageControl: UIPageControl!
    @IBOutlet weak var FloorViewContraint: NSLayoutConstraint!
    
    @IBOutlet weak var ScrollFullView: UIScrollView!
    var shareImage : UIImageView?
    
    //가게의 정보를 이전 페이지에서 부터 가져온다.
    var storeInfo : MessageInfo?
    //api기능이 들어있는 곳에서 기능을 가져온다.
    let apiVeiwModle = APIViewModel()
    //NSCache는 싱글톤으로 하여서 어디서든 사용가능하도록 해야한다.
    let imageCache = MainViewModel.shared.NsCacheIMG
    
    let personalInfo = MainViewModel.shared.PersonalInfo
    //
    var infoDetail : InfoArray?{
        didSet{
            DispatchQueue.main.async {
                self.setBasicUI()
            }
        }
    }
    
    var imageList : [ImageList]?{
        didSet{
            DispatchQueue.main.async {
                self.setPageView()
            }
        }
    }
    
    var WhiteFlag : Bool = false
    
    var statusBarStyle: UIStatusBarStyle = .lightContent

       override var preferredStatusBarStyle: UIStatusBarStyle{
           
           return statusBarStyle
         }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        print(storeInfo!.id)
        
        apiVeiwModle.getInfodetail(id: storeInfo!.id) { (result) in
            switch result {
                
            case .success(let infoArray):
                self.infoDetail = infoArray
            case .failure(_):
                print("got Error from infoDetail")
            }
        }
        
        apiVeiwModle.getImageList(id: storeInfo!.id) { (result) in
            switch result {
                
            case .success(let imgList):
                self.imageList = imgList
            case .failure(_):
                print("got Error from getImageList")
            }
        }
        
        setPageView()
        seperateTag(tag: storeInfo!.tag)
        settingFloorHeight()
        ScrollView.delegate = self
        ScrollFullView.delegate = self
            
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
    }
    
    //이 부분은 스크롤뷰의 위치를 설정해주는 부분이다.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //현재 보고 있는 스크롤뷰의 x값에 화면의 너비로 나눠준다.
        let pageNumber = ScrollView.contentOffset.x / view.bounds.width
        //그리고 현재 pageControll의 현재 위치를 설정해준다.
        PageControl.currentPage = Int(pageNumber)
       }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffsetY = ScrollFullView.contentOffset.y / 150
        
        if contentOffsetY > 1{
            
            if WhiteFlag {
            navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                setStatusBar(alpha: 1, tag: 1)
                removeStatusBar(tag: 2)
                statusBarStyle = .darkContent
                setNeedsStatusBarAppearanceUpdate()
                WhiteFlag = false
            }

        }
        else if contentOffsetY  < 1 {
            
            if WhiteFlag == false {
            navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
                removeStatusBar(tag: 1)
                //setStatusBar(alpha: 0, tag: 2)
                statusBarStyle = .lightContent
                setNeedsStatusBarAppearanceUpdate()
                WhiteFlag = true
            }


        }
        

    }
    
    //전화 걸어주는 함수
    @IBAction func CallStoreBtn(_ sender: Any) {
        
        guard  let infoDetail = infoDetail  else {
            return
        }
        
        guard let phoneCallURL = URL(string: "tel://\(infoDetail.tel)") else {
            return
        }
        
        let application:UIApplication = UIApplication.shared
        
        if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }

        
    }
    
    @IBAction func ShareBtn(_ sender: Any) {
        
        let text : String = " [오늘어때] 앱에서 보내드립니다! \n\n \(storeInfo!.name) \n\n \(storeInfo!.addr)"
        
        if let sharedImage = shareImage {
                
            let activityVC = UIActivityViewController(activityItems: [text, sharedImage.image!], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
                 
            self.present(activityVC, animated: true, completion: nil)
        }
        else {
            
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
                            
            self.present(activityVC, animated: true, completion: nil)
            
        }
     
    
    }
    
    @IBAction func HereSelectBtn(_ sender: Any) {
        
        guard let storeInfo = storeInfo , let  personalInfo = personalInfo else {
            print("HereSelectBtn storeInfo or userInfo empty")
            return}
        
        let sendSelectInfo = SendSelectList(id: storeInfo.id, userid: personalInfo.id )
        
        apiVeiwModle.SendStatus(sendMessage: sendSelectInfo, commend: "POST") { (result) in
            
            switch result{
                
            case .success(let messageResult):
                //함수 내부에 main 쓰레드를 해주면 self를 두번 해준다고 오료가 발생한다. 따라서 함수 밖에서 해줘야한다.
                DispatchQueue.main.async {
                    self.SendStatusMessage(message: messageResult.message)
                }

            case .failure(_):
                DispatchQueue.main.async {
                    self.SendStatusMessage(message: "Error")
                }
            }
        }
    }
    
    
}

extension DetailInfoViewController{
    
    
    func removeStatusBar(tag : Int){
        view.viewWithTag(tag)?.removeFromSuperview()
    }
    
    func setStatusBar(alpha: CGFloat, tag : Int) {
        
           let statusBarFrame: CGRect
           if #available(iOS 13.0, *) {
               statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
           } else {
               statusBarFrame = UIApplication.shared.statusBarFrame
           }
        
           let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: alpha)
                statusBarView.tag = tag
                view.addSubview(statusBarView)
            }
    
    
    func SendStatusMessage(message : String){
        
        print("message : \(message)")
        var alert : UIAlertController?
        
        if message == "Success" {
            alert = apiVeiwModle.showAlert(title: "등록성공!", text: "마이리스트에 확인 하실 수 있습니다!!")
        }
        else if message == "Duplicate values"{
            alert = apiVeiwModle.showAlert(title: "중복등록!", text: "마이리스트에 이미 동록하셨습니다!")
        }
        else {
            alert = apiVeiwModle.showAlert(title: "오류", text: "죄송합니다! 서버에 오류가 발생했습니다.")
        }
        
        present(alert!, animated: true, completion: nil)
        
    }
    
    //아래 버튼 부분의 높이를 지정해준다.
    func settingFloorHeight(){
        
        let sizeOfView = view.bounds.height
        
        if sizeOfView <= 800{
            FloorViewContraint.constant = 75
        }
        else{
            FloorViewContraint.constant = 100
        }
        
    }
    
    //StackView에 태그를 넣어준다.
    func seperateTag(tag : String){
        
        let hashTag = tag.components(separatedBy: ",")
    
        for element in hashTag {
            let label = UILabel()
            label.text = element
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = UIColor.lightGray
            TagStackView.addArrangedSubview(label)
        }
        
    }
        
    func setBasicUI(){
        
        guard let storeInfo = storeInfo , let infoDetail = infoDetail else {return}
        
        StoreName.text = storeInfo.name
        StoreAddr.text = storeInfo.addr
        
        StorePhone.text = infoDetail.tel
        StoreRate.text = String(infoDetail.avg)
        StoreComment.text = infoDetail.info
        
        setMapView(name: storeInfo.name, lati: infoDetail.latitude, longi: infoDetail.longitude)
    }
    
    //좌표를 찍어준다.
    func setMapView(name : String, lati : String, longi : String){
        
        guard  let latitude = Double(lati), let longitude = Double(longi) else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.title = name
               
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        MapView.setRegion(region, animated: true)
        MapView.addAnnotation(annotation)
        
    }
    
    //이미지를 넣어준다.
    func setPageView(){
        
        guard let ImageArray = imageList else {return}
        
       // let ImageArray = ["http://img.mintpass.kr/1/1.jpg", "http://img.mintpass.kr/1/2.jpg"]
        PageControl.numberOfPages = 0
        for index in 0..<ImageArray.count{
            
            //NSCache로 구현하여 중복된 이미지의 링크가 있다면 있는 것을 사용한다.
            if let ImageData =  imageCache.object(forKey: ImageArray[index].url as NSString) {
                print("get From NScache")
                setImageView(Image: ImageData)
            }
            else{
             
                apiVeiwModle.getImageData(urlLink: ImageArray[index].url) { result in
                               
                  switch result {
                                   
                    case .success(let ImageData):
                        print("get From Server")
                        self.setImageView(Image: ImageData)
                    case .failure(_):
                        print("get Image Fail")
                                   
                    }
                               
                }
                
            }
            
        }
        
    }
    
    func setImageView(Image : UIImage){
        
        if shareImage == nil {
            
            shareImage = UIImageView(image: Image)
            print("GetImage")
        }
        
        //이미지를 넣어줄 프레인의 초기값
         var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        //이미지를 붙일 부분 부터 시작해서 ScrollView의 높이 많큰과 ScrollView의 너비 만큼 Frame을 변경해준다.
        frame  = CGRect(x: FrameWidthConstraint.constant, y: 0 , width: view.bounds.width, height: ScrollView.bounds.height)
        
        //너비를 증가시켜준다.
        FrameWidthConstraint.constant += view.bounds.width
        
        //UIImageView로 화면을 만들어주고 거기에 이미지를 넣어준다.
        let imgview = UIImageView(frame: frame)
        imgview.image = Image
        //꽉찬화면으로
        imgview.contentMode = .scaleToFill
        
        DispatchQueue.main.async {
            self.PageControl.numberOfPages += 1
            self.FrameView.addSubview(imgview)
        }
        
    }
    
}
