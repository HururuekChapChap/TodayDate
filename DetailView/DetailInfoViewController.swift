//
//  DetailInfoViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/26.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit

class DetailInfoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var FrameView: UIView!
    @IBOutlet weak var FrameWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var PageControl: UIPageControl!
    
    let apiVeiwModle = APIViewModel()
    //NSCache는 싱글톤으로 하여서 어디서든 사용가능하도록 해야한다.
    let imageCache = MainViewModel.shared.NsCacheIMG
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func setPageView(){
        
        let ImageArray = ["http://img.mintpass.kr/1/1.jpg", "http://img.mintpass.kr/1/2.jpg"]
        PageControl.numberOfPages = 0
        for index in 0..<ImageArray.count{
            
            //NSCache로 구현하여 중복된 이미지의 링크가 있다면 있는 것을 사용한다.
            if let ImageData =  imageCache.object(forKey: ImageArray[index] as NSString) {
                print("get From NScache")
                setImageView(Image: ImageData)
            }
            else{
             
                apiVeiwModle.getImageData(urlLink: ImageArray[index]) { result in
                               
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
