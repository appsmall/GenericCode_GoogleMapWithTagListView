//
//  RoundCornerView.swift
//  Scavenger Hunt
//
//  Created by Rahul Chopra on 21/08/18.
//  Copyright © 2018 AppSmall. All rights reserved.
//

import UIKit

@IBDesignable
class RoundCornerView: UIView {
    
    @IBInspectable var radius : CGFloat = 0{
        didSet{
            updateView()
        }
    }
    @IBInspectable var borderWidth : CGFloat = 0{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView(){
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
    }
}
