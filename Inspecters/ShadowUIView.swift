//
//  ShadowUIView.swift
//  TodayDate
//
//  Created by yoon tae soo on 2020/05/30.
//  Copyright © 2020 yoon tae soo. All rights reserved.
//

import UIKit
@IBDesignable
class ShadowUIView: UIView {
    
    @IBInspectable var ShadowColor : UIColor = .clear{
        didSet{
            layer.shadowColor = ShadowColor.cgColor
        }
    }
    
    @IBInspectable var ShadowX : CGFloat = 0
     
    @IBInspectable var ShadowY : CGFloat = 0
        
    
    @IBInspectable var ShadowOpacity : Float = 0{
        didSet{
            layer.shadowOpacity = ShadowOpacity
        }
    }
    @IBInspectable var ShadowRadius : CGFloat = 0{
        didSet{
            layer.shadowRadius = ShadowRadius
        }
    }
    
    override func draw(_ rect: CGRect) {
           // Drawing code
        layer.shadowOffset = CGSize(width: ShadowX, height: ShadowY)
       }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
