//
//  UIButtonInspecter.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/17.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit

@IBDesignable
class UIButtonInspecter: UIButton {

//    @IBInspectable var cornerRadius : CGFloat = 0 {
//        didSet {
//            layer.cornerRadius = cornerRadius
//        }
//    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor = .clear {
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        layer.cornerRadius = frame.height / 2
    }


}
