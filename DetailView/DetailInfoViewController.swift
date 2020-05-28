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
    
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var FrameView: UIView!
    @IBOutlet weak var FrameWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var PageControl: UIPageControl!
    
    //가게의 정보를 이전 페이지에서 부터 가져온다.
    var storeInfo : MessageInfo?
    //api기능이 들어있는 곳에서 기능을 가져온다.
    let apiVeiwModle = APIViewModel()
    //NSCache는 싱글톤으로 하여서 어디서든 사용가능하도록 해야한다.
    let imageCache = MainViewModel.shared.NsCacheIMG
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        ScrollView.delegate = self
            
    }
    
    //이 부분은 스크롤뷰의 위치를 설정해주는 부분이다.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //현재 보고 있는 스크롤뷰의 x값에 화면의 너비로 나눠준다.
        let pageNumber = ScrollView.contentOffset.x / view.bounds.width
        //그리고 현재 pageControll의 현재 위치를 설정해준다.
        PageControl.currentPage = Int(pageNumber)
       }
    
}

extension DetailInfoViewController{
    
    func setBasicUI(){
        
        guard let storeInfo = storeInfo , let infoDetail = infoDetail else {return}
        
        StoreName.text = storeInfo.name
        StoreAddr.text = storeInfo.addr
        
        StorePhone.text = infoDetail.tel
        StoreRate.text = String(infoDetail.avg)
        StoreComment.text = infoDetail.info
        
        setMapView(name: storeInfo.name, lati: infoDetail.latitude, longi: infoDetail.longitude)
    }
    
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
