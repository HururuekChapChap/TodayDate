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
    var searchItem : String?
    var storeInfo : StoreInfo?{
        didSet{
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    let apiViewModel = APIViewModel()
  
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
                print("Fail")
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    
}

extension DetailViewController {
    
    
}

extension DetailViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeInfo?.info.count ?? 0
      }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else {return UITableViewCell()}
        
        guard let storeInfo = storeInfo else {
            return UITableViewCell()
        }
        
        cell.updateUI(StoreInfo: storeInfo.info[indexPath.row])
        
          return cell
      }
    
    
      
    
}
