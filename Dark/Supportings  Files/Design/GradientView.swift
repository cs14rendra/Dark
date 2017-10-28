//
//  GradientView.swift
//  Happy Days
//
//  Created by surendra kumar on 7/8/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable final class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: superview!.frame.size.width,
                                height: superview!.frame.size.height)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        layer.insertSublayer(gradient, at: 0)
    }
    
}
