//
//  MyListCollectionViewCell.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/06/03.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit

class MyListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var MyListImage: UIImageView!
    @IBOutlet weak var MyListName: UILabel!
    
    let apiViewModel = APIViewModel()
    let mainViewModel = MainViewModel.shared
    
    var tapHandler: (()->Void)?
    
    @IBOutlet weak var MyListCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var uiImage : UIImage?{
        didSet{
            guard let uiImage = uiImage else {return}
            
            DispatchQueue.main.async {
                
                self.MyListImage.image = uiImage
            }
        }
    }
    @IBAction func MyListSettingBtn(_ sender: Any) {
        
        tapHandler?()
        
    }
    
    
    func updateUI(listItem : ListDetail){
        
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
        
        MyListName.text = listItem.name
        
    }
    
}
