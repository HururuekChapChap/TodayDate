//
//  DetailViewController.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/17.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var TagView: UIView!
    @IBOutlet weak var TagWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var TagLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var VerticalStackView: UIStackView!
    var isTageShowing = false
    
    var searchItem : String?
    var clickedButton : Int?
    var tagButtonList : [UIButton] = [UIButton]()
    
    var storeInfo : StoreInfo?{
        didSet{
            sortByWeather()
            apiViewModel.getTagList(storeInfo: storeInfo!) { (set) in
                DispatchQueue.main.async {
                    self.setTagButton(sets: set)
                }
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }
            
        }
    }
    var tempStoreInfo : [MessageInfo]?
    
    let apiViewModel = APIViewModel()
    let mainViewModel = MainViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네이게이션 바를 제거해줌, 숨기는것이 아님 투명하게 해줌
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //navigationController?.navigationBar.shadowImage = UIImage() //네비게이션 아래 선을 제거 해줌
        print(searchItem!)
        
        apiViewModel.SendUserInfoPost(sendMessage: searchItem!) { (Result) in
            
            switch Result{
                
            case .success(let Infos) :
                print(Infos)
                self.storeInfo = Infos
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "오류", text: "서버로 부터 데이터를 받아오지 못 했습니다.")
                }
                
            }
            
        }
        
        TagWidthConstraint.constant = view.bounds.width
        TagLeadingConstraint.constant = (view.bounds.width + 5) * -1
        // Do any additional setup after loading the view.
    }
    
    //태그 뷰 보여주게 하는 함수
    @IBAction func FunctionDescription(_ sender: Any) {
        
        if isTageShowing {
            TagLeadingConstraint.constant = (TagWidthConstraint.constant + 5) * -1
        }
        else {
            self.TagView.alpha = 1
            TagLeadingConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            super.view.layoutIfNeeded()
        }) { finish in
            
            if self.isTageShowing {
                self.TagView.alpha = 0
            }
            
            self.isTageShowing = !self.isTageShowing
            
        }

    }
    
    @IBAction func TagSearchBtn(_ sender: Any) {
//        guard let storeInfo = storeInfo else {return}
        guard let searchItem = searchItem else {return}
        
//        let filtered = storeInfo.info.filter { (message) -> Bool in
//
//            let tags = message.tag.components(separatedBy: ", ")
//
//            for tag in tags {
//
//                if tag == searchItem {
//                    return true
//                }
//
//            }
//
//            return false
//        }
//
        tempStoreInfo = apiViewModel.classifyStore(searchItem)
        
    DispatchQueue.main.async {
        self.tableView.reloadData()
        
    }
        
    }
    
}

extension DetailViewController {
    
    func setTagButton(sets : Set<String>){
        
        let tagList : [String] = sets.map { (element) -> String in
            return String(element)
        }
        
        let stackViewCnt : Int = Int(sets.count / 3)
        var inputCnt : Int = 0
       // var horizonStackView : [UIStackView] = [UIStackView]()
        
        for stackTimes in 0...stackViewCnt {
            
            if stackTimes == stackViewCnt && sets.count % 3 == 0 {
                continue
            }
            
            let stackview = UIStackView()
            stackview.axis = .horizontal
            stackview.distribution = .fillEqually
            stackview.alignment = .fill
            
            var temp = inputCnt
            inputCnt += 3
            while (temp < inputCnt && temp < sets.count){
                
                let button = UIButton()
                button.tag = temp
                button.setTitle(tagList[temp], for: .normal)
                button.setTitleColor(UIColor.black, for: .normal)
                button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
                stackview.addArrangedSubview(button)
                tagButtonList.append(button)
                temp += 1
            }
            
            //이 스택 뷰를 상위 스택뷰에 넣어준다.
            VerticalStackView.addArrangedSubview(stackview)
        }
  
    }
    
    @objc func buttonTapped(sender : UIButton){
        
        if clickedButton == nil {
            sender.setTitleColor(UIColor.orange, for: .normal)
            searchItem = sender.titleLabel?.text
            clickedButton = sender.tag
        }
        else {
            
            tagButtonList[clickedButton!].setTitleColor(UIColor.black, for: .normal)
            sender.setTitleColor(UIColor.orange, for: .normal)
            searchItem = sender.titleLabel?.text
            clickedButton = sender.tag
        }
        
    }
    
}

extension DetailViewController {
    
    func showErrorAlert(title: String, text : String)  {

            let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
            
        let Exit = UIAlertAction(title: "뒤로가기", style: .cancel) { (alert) in
            self.navigationController?.popViewController(animated: true)
        }
     
         alert.addAction(Exit)
            
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ContentSegue" {
            
            guard let vc = segue.destination as? DetailInfoViewController, let storeInfo = sender as? MessageInfo else {return}
            
            vc.storeInfo = storeInfo
            
        }
        
    }
    
    func sortByWeather(){
        
        guard let StoreInfo = storeInfo, let weatherInfo = mainViewModel.weatherInfo?.openWeather else{return}
        
        print("날씨 정보 : \(weatherInfo.weather[0].id)")
        
        let weatherID = weatherInfo.weather[0].id
        
       // let test = "shower rain"
        
        if weatherID < 300 {
            tempStoreInfo = StoreInfo.info.sorted(by: { (element1, element2) -> Bool in
                
                guard let item1 = element1.Thunderstorm, let item2 = element2.Thunderstorm else {return true}
                
                //return element1.Thunderstorm > element2.Thunderstorm
                
                return item1 > item2
            })
        }
        else if weatherID < 500 {
            tempStoreInfo = StoreInfo.info.sorted(by: { (element1, element2) -> Bool in
                
                guard let item1 = element1.Drizzle, let item2 = element2.Drizzle else {return true}
                
                return item1 > item2
               // return element1.Drizzle > element2.Drizzle
                
                
            })
        }
        else if weatherID < 600 {
            tempStoreInfo = StoreInfo.info.sorted(by: { (element1, element2) -> Bool in
                
                guard let item1 = element1.Rain, let item2 = element2.Rain else {return true}
                               
                return item1 > item2
                //return element1.Rain > element2.Rain
            })
        }
        else if weatherID < 700 {
            tempStoreInfo = StoreInfo.info.sorted(by: { (element1, element2) -> Bool in
                
                guard let item1 = element1.Snow, let item2 = element2.Snow else {return true}
                               
                return item1 > item2
                
                //return element1.Snow > element2.Snow
            })
        }
        else if weatherID < 800 {
            tempStoreInfo = StoreInfo.info.sorted(by: { (element1, element2) -> Bool in
                
                guard let item1 = element1.Atmosphere, let item2 = element2.Atmosphere else {return true}
                               
                return item1 > item2
                
                //return element1.Atmosphere > element2.Atmosphere
            })
        }
        else if weatherID == 800 {
            tempStoreInfo = StoreInfo.info.sorted(by: { (element1, element2) -> Bool in
                
                guard let item1 = element1.Clear, let item2 = element2.Clear else {return true}
                               
                return item1 > item2
                
                //return element1.Clear > element2.Clear
            })
        }
        else if weatherID > 800 {
            tempStoreInfo = StoreInfo.info.sorted(by: { (element1, element2) -> Bool in
                
                guard let item1 = element1.Clouds, let item2 = element2.Clouds else {return true}
                               
                return item1 > item2
                
                //return element1.Clouds > element2.Clouds
            })
        }
        else {
            tempStoreInfo = StoreInfo.info
        }
        
    }
    
}

extension DetailViewController : UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempStoreInfo?.count ?? 0
      }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else {return UITableViewCell()}
        
        guard let storeInfo = tempStoreInfo else {
            return UITableViewCell()
        }
        
        cell.updateUI(StoreInfo: storeInfo[indexPath.row], indexPath: indexPath.row)
        
          return cell
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let storeInfo = tempStoreInfo else {return}
        
        performSegue(withIdentifier: "ContentSegue", sender: storeInfo[indexPath.row])
    }
    
}
