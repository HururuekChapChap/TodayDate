//
//  DetailTableViewCell.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/17.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var StoreName: UILabel!
    @IBOutlet weak var StoreAddr: UILabel!
    @IBOutlet weak var StoreImg: UIImageView!
    @IBOutlet weak var RankView: UIViewInspecter!
    @IBOutlet weak var RankLabel: UILabel!
    
    let mainViewModel = MainViewModel.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    //https://baked-corn.tistory.com/51
    override func prepareForReuse() {
        super.prepareForReuse()
        
        StoreName.text = nil
        StoreImg.image = nil
        StoreAddr.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(StoreInfo : MessageInfo, indexPath : Int){
        //순위를 보여주는 곳
        if indexPath < 3 {
            
            RankView.alpha = 1
            //RankLabel.text = String(indexPath + 1)
        }
        else{
            RankView.alpha = 0
        }
        
        StoreName.text = StoreInfo.name
        StoreAddr.text = StoreInfo.addr
        
        //이미지의 테두리 설정!
        StoreImg.layer.borderWidth = 1
        StoreImg.layer.borderColor = UIColor.black.cgColor
        StoreImg.layer.cornerRadius = 5
        
        DispatchQueue.global().async {
            
            var tempImg : UIImage
            
            if let Image = self.mainViewModel.NsCacheIMG.object(forKey: StoreInfo.img as NSString){
                tempImg = Image
            }
            else if let ImageData = try? Data(contentsOf: URL(string: StoreInfo.img)!) {
                
                self.mainViewModel.NsCacheIMG.setObject(UIImage(data: ImageData)!, forKey: StoreInfo.img as NSString)
                
                tempImg = UIImage(data: ImageData)!
            }
            else{
                tempImg = UIImage(named: "Asset 20.png")!
            }
      
            DispatchQueue.main.async {
                self.StoreImg.image = tempImg
            }
            
        }
    }

}
