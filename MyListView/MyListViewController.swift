//
//  MyListViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/06/03.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit

class MyListViewController: UIViewController {
    
    var WhiteFlag : Bool = false
    var statusBarStyle: UIStatusBarStyle = .lightContent

    let myListViewModel = MyListViewModel()
    let apiViewModel = APIViewModel()
    let personalId = MainViewModel.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return statusBarStyle
      }
    @IBOutlet weak var MyListCollectionView: UICollectionView!
    
    @IBOutlet var StaratingView: UIViewInspecter!
    
    var sendInfomation : SendSelectList?
    
    //별점 버튼 변수
    
    var starRating : Int = 0
    
    @IBOutlet weak var StarAction1: UIButton!
    @IBOutlet weak var StarAction2: UIButton!
    @IBOutlet weak var StarAction3: UIButton!
    @IBOutlet weak var StarAction4: UIButton!
    @IBOutlet weak var StarAction5: UIButton!
    @IBOutlet weak var DimeView: UIView!
    
    //버튼을 담기 위해서는 이렇게 버튼 배열을 만들고 버튼 배열 클래스를 생성해줘야한다.
    var uiButtonlist : [UIButton] = [UIButton]()
    
    var listDetail : [ListDetail]?{
        didSet{
            DispatchQueue.main.async {
                self.MyListCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.systemPink]
    
        myListViewModel.getMyList(userId: personalId.PersonalInfo!.id) { (result) in
            
            switch result {
                
            case .success(let getresult):
                self.listDetail = getresult.listdetail
            case .failure(_):
                
                DispatchQueue.main.async {
                    
                    self.showErrorAlert(title: "에러!!", text: "서버로 부터 데이터를 가져오지 못했습니다.")
                    
                }
                
            }
        }
        
        StaratingView.bounds.size.width = 275
        StaratingView.bounds.size.height = 200
        insertUIButton()
        // Do any additional setup after loading the view.
      }
    
    override func viewWillDisappear(_ animated: Bool) {
           navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
     }
    
    //https://jintaewoo.tistory.com/30
    //위치에 따라 네비게이션 변경 색 변경 방법
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffsetY = scrollView.contentOffset.y / 160
        
        if contentOffsetY > 1{
            
            if WhiteFlag {
            navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                setStatusBar(alpha: 1, tag: 1)
                removeStatusBar(tag: 2)
                statusBarStyle = .darkContent
                //https://developer.apple.com/documentation/uikit/uiviewcontroller/1621354-setneedsstatusbarappearanceupdat
                //상태바를 변경할 때 시스템에 알려줘야함
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
    
}

extension MyListViewController {
    
    //https://stackoverflow.com/questions/52808945/dispatchqueue-cannot-be-called-with-ascopy-no-on-non-main-thread
    //ShowAlert할 때 생기는 쓰레드 문제
    //Constent OffSet의 내용
    //http://blog.naver.com/PostView.nhn?blogId=jdub7138&logNo=220415845525&parentCategoryNo=&categoryNo=112&viewDate=&isShowPopularPosts=false&from=postView
    //https://www.youtube.com/watch?v=rNy6aQQYbuY 참고영상
       func showErrorAlert(title: String, text : String)  {

               let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
               
           let Exit = UIAlertAction(title: "뒤로가기", style: .cancel) { (alert) in
               self.navigationController?.popViewController(animated: true)
           }
        
            alert.addAction(Exit)
               
           present(alert, animated: true, completion: nil)
       }
    
    // ActionSheet를 보여주는 함수
    // .cancel이 맨 밑으로 / .destructive가 아래로 / .default는 맨 위로 간다.
    func showActionSheet(title : String, text : String, id : Int){
        
        guard let personal = personalId.PersonalInfo else {return}
        
         sendInfomation = SendSelectList(id: id, userid: personal.id)
        
        guard let sendInfomation = sendInfomation else {return}
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .actionSheet)
        
        let exit = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        let delete = UIAlertAction(title: "삭제하기", style: .destructive) { (alert) in
            print("삭제")
            
            self.apiViewModel.SendStatus(sendMessage: sendInfomation, commend: "DELETE") { (result) in
                
                switch result {
                    
                case .success(_):
                    
                    self.myListViewModel.getMyList(userId: personal.id) { (result) in
                               
                               switch result {
                                   
                               case .success(let getresult):
                                   self.listDetail = getresult.listdetail
                               case .failure(_):
                                   
                                   DispatchQueue.main.async {
                                       
                                       self.showErrorAlert(title: "에러!!", text: "서버로 부터 데이터를 가져오지 못했습니다.")
                                       
                                   }
                                   
                               }
                           }
                    
                    
                case .failure(_):
                    DispatchQueue.main.async {
                        let alert = self.apiViewModel.showAlert(title: "오류!!", text: "서버와 연결 할 수 없습니다.")
                        self.presendFunc(alert: alert)
                    }
                }
            }
            
        }
        
        let star = UIAlertAction(title: "별점주기", style: .default) { (alert) in
            print("별점주기")
            
            self.showStarRatingView()
            
        }
        
        alert.addAction(star)
        alert.addAction(delete)
        alert.addAction(exit)
        
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //
    func showStarRatingView(){
        view.addSubview(self.StaratingView)
        StaratingView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        StaratingView.center = CGPoint(x: view.frame.width / 2, y: (view.frame.height / 2) - 100)
        StaratingView.transform = CGAffineTransform(rotationAngle: 1.8)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.DimeView.alpha = 0.7
            self.StaratingView.transform = .identity
        }, completion: nil)
        
    }
    
    // 경고를 보여주는 것
    func presendFunc(alert : UIAlertController){
        present(alert, animated: true, completion: nil)
    }
    // statusBar에 뷰를 넣어 줬을 때 삭제하는 함수 -> 태그를 넣어줘서 삭제해줘야한다.
    func removeStatusBar(tag : Int){
         view.viewWithTag(tag)?.removeFromSuperview()
     }
    // 상태에 뷰를 넣어주는 함수 -> 뷰를 넣어주는 방식이다.
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
    
    //상세 페이지로 넘어가는 뷰
    func ChageViewToDetailInfo(index : Int){
        
        guard let listDetail = listDetail else {return}
        
         if listDetail.count <= 0 {return}
        
        let MyListLastestIndex = listDetail[index]
                       
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailInfoViewController") as? DetailInfoViewController else{return}
                                            
        vc.storeInfo = MessageInfo(id: MyListLastestIndex.id, name: MyListLastestIndex.name, addr: MyListLastestIndex.addr, img: MyListLastestIndex.img, tag: MyListLastestIndex.tag, Thunderstorm: nil, Drizzle: nil, Rain: nil, Snow: nil, Atmosphere: nil, Clear: nil, Clouds: nil)

            UINavigationController(rootViewController: vc).modalTransitionStyle = .crossDissolve
            self.navigationController?.pushViewController(vc, animated: true)
    }
        
}


extension MyListViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDetail?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyListCell", for: indexPath) as? MyListCollectionViewCell else {
            
            return UICollectionViewCell()
        }
        
        guard let listDetail = listDetail else {return cell}
        
        cell.updateUI(listItem: listDetail[indexPath.item])
        
        cell.tapHandler = {
            
            DispatchQueue.main.async {
                self.showActionSheet(title: "무엇을 원하시나요?", text: "선택해주세요!", id : listDetail[indexPath.item].id)
            }
            
            //print(listDetail[indexPath.item].id)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch  kind {
        case UICollectionView.elementKindSectionHeader:
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyListHeaderCell", for: indexPath) as? MyListCollectionReusableView else {
                
                return UICollectionReusableView()
            }
            
            guard let listDetail = listDetail else {return header}
            
            if listDetail.count <= 0 {
                
                header.MyListLastestImage.image = UIImage()
                print("리스트가 0 보다 작습니다.")
                return header
                
            }
            
            header.upDateUI(listItem: listDetail[listDetail.count - 1])
            
            header.tapHandler = {
            
                self.ChageViewToDetailInfo(index: listDetail.count - 1)
            }
            
            return header
            
        default:
            return UICollectionReusableView()
        }
    }
}

extension MyListViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        ChageViewToDetailInfo(index: indexPath.item)
        
    }
    
}

extension MyListViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOFitem :CGFloat = 2
        let itemSpacing : CGFloat = 3
        let marginTotal : CGFloat = 4
        let width : CGFloat = (self.view.bounds.width - (itemSpacing * (numberOFitem - 1) + marginTotal )) / numberOFitem
        let height : CGFloat = width + 10
        
        
        return CGSize(width: width, height: height)
        
    }
    
}

//별점 버튼의 기능을 담당하는 함수
extension MyListViewController {
    
    //https://stackoverflow.com/questions/28955620/array-of-uibuttons-or-method-uibuttonnamed-string
    //버튼을 배열로 담는 방법
    func insertUIButton(){
        uiButtonlist = [StarAction1, StarAction2,StarAction3,StarAction4,StarAction5]
    }
    //https://stackoverflow.com/questions/26837371/how-to-change-uibutton-image-in-swift
    //버튼의 이미지 변경하는 방법
    //https://stackoverflow.com/questions/18717830/how-to-get-system-images-programmatically-example-disclosure-chevron
    //시스템 이미지 사용하는 방법
    func ChangeStarImage(star : Int){
        
        for item in 0..<5{
            
            if item > star {
                uiButtonlist[item].setImage(UIImage(systemName: "star"), for: .normal)
            }
            else {
                uiButtonlist[item].setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
            
        }
        
    }
    
    func closeRatingView(){
        UIView.animate(withDuration: 0.5) {
            self.DimeView.alpha = 0
            self.StaratingView.removeFromSuperview()
        }
               
        self.ChangeStarImage(star: -1)
        self.starRating = 0
    }
    
    @IBAction func StarAction1Btn(_ sender: Any) {
        
        ChangeStarImage(star: 0)
        starRating = 1
     }
    @IBAction func StarAction2Btn(_ sender: Any) {
         
        ChangeStarImage(star: 1)
        starRating = 2
     }
    @IBAction func StarAction3Btn(_ sender: Any) {
         
        ChangeStarImage(star: 2)
        starRating = 3
     }
    @IBAction func StarAction4Btn(_ sender: Any) {
         
        ChangeStarImage(star: 3)
        starRating = 4
     }
    @IBAction func StarAction5Btn(_ sender: Any) {
         
        ChangeStarImage(star: 4)
        starRating = 5
     }
    
    @IBAction func StarRatingCancelBtn(_ sender: Any) {
        
        closeRatingView()
        
       }
    
    @IBAction func StarRatingPostBtn(_ sender: Any) {
        
        guard let sendInfomation = sendInfomation else {return}
        
        if starRating < 1 {
            
            DispatchQueue.main.async {
                let alert = self.apiViewModel.showAlert(title: "경고", text: "0 점은 안됩니다!")
                self.presendFunc(alert: alert)
            }
            
            
            return
        }
        
        myListViewModel.SendStarRating(sendMessage: sendInfomation, rating: starRating) { (result) in
            
            switch result {
                
            case .success(let resultMessage):
                print(resultMessage.message)
                
                DispatchQueue.main.async {
                    let alert = self.apiViewModel.showAlert(title: "등록성공", text: "별점이 성공적으로 반영됐습니다. 감사합니다!")
                    self.closeRatingView()
                    self.presendFunc(alert: alert)
                }
                
            case .failure(_):
                
                DispatchQueue.main.async {
                    let alert = self.apiViewModel.showAlert(title: "오류", text: "서버에 오류가 생겨 반영되지 못했습니다.")
                    self.presendFunc(alert: alert)
                }
            }
        }
        
        
       }
       
    
}
