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
    
    func updateUI(StoreInfo : MessageInfo){
        StoreName.text = StoreInfo.name
        StoreAddr.text = StoreInfo.addr
        
        //이미지의 테두리 설정!
        StoreImg.layer.borderWidth = 1
        StoreImg.layer.borderColor = UIColor.black.cgColor
        StoreImg.layer.cornerRadius = 15
        
        DispatchQueue.global().async {
            
            guard let imageData = try? Data(contentsOf: URL(string: StoreInfo.img)!) else {
                self.StoreImg.image = UIImage(named: "Sun.png")
                return
            }
            
            DispatchQueue.main.async {
                self.StoreImg.image = UIImage(data: imageData)
            }
            
        }
    }

}
