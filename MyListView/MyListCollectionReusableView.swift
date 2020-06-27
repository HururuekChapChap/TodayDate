//
//  MyListCollectionReusableView.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/06/03.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit

class MyListCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var MyListLastestImage: UIImageView!
    
    let apiViewModel = APIViewModel()
    let mainViewModel = MainViewModel.shared
    
    var tapHandler : (()->Void)?
     
     var uiImage : UIImage?{
         didSet{
             guard let uiImage = uiImage else {return}
             
             DispatchQueue.main.async {
                 
                 self.MyListLastestImage.image = uiImage
             }
         }
     }
    
    @IBAction func MyListLastestBtn(_ sender: Any) {
        
        tapHandler?()
    }
    
    
    
    func upDateUI(listItem : ListDetail){
        
        let imageUrl = listItem.img
        
        if let image = mainViewModel.NsCacheIMG.object(forKey: imageUrl as NSString){
            uiImage = image
        }
        else{
            apiViewModel.getImageData(urlLink: imageUrl) { (result) in
                
                switch result {
                    
                case .success(let getResult):
                    self.uiImage = getResult
                case .failure(_):
                    self.uiImage = UIImage(named: "Asset 20.png")!
                }
                
            }
        }
        
    }
    
}
