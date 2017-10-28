//
//  CustomSwitch.swift
//  Custom Switch
//
//  Created by Chad Timmerman on 3/4/15.
//  Copyright (c) 2015 Chad Timmerman. All rights reserved.
//

import UIKit
protocol CustomSwitchDelegate {
    func customSwitchValueDidChange(value : Bool)
}
@IBDesignable
class CustomSwitch: UIView {
    
    @IBInspectable var customPink : UIColor = UIColor.clear{
        didSet{
           // self.buttonWindow.backgroundColor = customPink
        }
    }
    var backgroundView: UIView!

    var onButton: UIButton!
    var offButton: UIButton!
    var buttonWindow: UIView!
    
    var onLabel: UILabel!
    var offLabel: UILabel!
    var centerCircleLabel: UILabel!
    
    let whiteColor = UIColor.white
    let darkGreyColor = UIColor(red:0.22, green:0.22, blue:0.22, alpha:1)
    
    var delegate : CustomSwitchDelegate?
    
    var isOff: Bool!{
        didSet{
            delegate?.customSwitchValueDidChange(value: self.isOff)
        }
    }

    override func draw(_ rect: CGRect) {
      
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
    
        backgroundView = UIView()
        backgroundView.frame = self.bounds
        backgroundView.backgroundColor = UIColor.gray
        backgroundView.layer.cornerRadius = 4.0
        self.addSubview(backgroundView)
        
        // Setup the Sliding Window
        
        buttonWindow = UIView()
        buttonWindow.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width / 2, height: self.bounds.size.height)
        buttonWindow.backgroundColor = customPink
        buttonWindow.layer.cornerRadius = 4.0
        self.addSubview(buttonWindow)
        
        // Setup the Buttons
        
        onButton = UIButton()
        onButton.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width / 2, height: self.bounds.size.height)
        onButton.backgroundColor = UIColor.clear
        onButton.isEnabled = false
        onButton.addTarget(self, action: #selector(CustomSwitch.toggleSwitch(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(onButton)
        
        offButton = UIButton()
        offButton.frame = CGRect(x: self.bounds.size.width / 2, y: 0.0, width: self.bounds.size.width / 2, height: self.bounds.size.height)
        offButton.backgroundColor = UIColor.clear
        offButton.isEnabled = true
        offButton.addTarget(self, action: #selector(CustomSwitch.toggleSwitch(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(offButton)

        // Setup the Labels
        
        onLabel = UILabel()
        onLabel.frame = CGRect(x: 0.0, y: (self.bounds.size.height / 2) - 25.0, width: self.bounds.size.width / 2, height: 50.0)
        onLabel.alpha = 1.0
        onLabel.text = "MALE"
        onLabel.textAlignment = NSTextAlignment.center
        onLabel.textColor = whiteColor
        onLabel.font = UIFont(name: "AvenirNext-Demibold", size: 15.0)
        onButton.addSubview(onLabel)
        
        offLabel = UILabel()
        offLabel.frame = CGRect(x: 0.0, y: (self.bounds.size.height / 2) - 25.0, width: self.bounds.size.width / 2, height: 50.0)
        offLabel.alpha = 1.0
        offLabel.text = "FEMALE"
        offLabel.textAlignment = NSTextAlignment.center
        offLabel.textColor = darkGreyColor
        offLabel.font = UIFont(name: "AvenirNext-Demibold", size: 15.0)
        offButton.addSubview(offLabel)
        
        // Set up the center Label
        
        centerCircleLabel = UILabel()
        centerCircleLabel.frame = CGRect(x: (self.bounds.size.width / 2) - 12.0, y: (self.bounds.size.height / 2) - 12.0, width: 24.0, height: 24.0)
        centerCircleLabel.text = "sex"
        centerCircleLabel.textAlignment = NSTextAlignment.center
        centerCircleLabel.textColor = UIColor(red:0.49, green:0.49, blue:0.49, alpha:1)
        centerCircleLabel.font = UIFont(name: "AvenirNext-Regular", size: 11.0)
        centerCircleLabel.backgroundColor = UIColor.yellow
        centerCircleLabel.layer.cornerRadius = 12.0
        centerCircleLabel.clipsToBounds = true
        self.addSubview(centerCircleLabel)
        
        isOff = false
        
    }
    
    @objc func toggleSwitch(_ sender: UIButton) {
        onOrOff(!isOff)
    }

    func onOrOff(_ on : Bool){
        
        if(on == isOff){
            return
        }
        isOff = on
        
        UIView.animate(withDuration: 0.4,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 14.0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: { () -> Void in
                self.buttonWindow.frame.origin.x += self.frame.size.width / 2 * (on ? 1 : -1)
            },
            completion: nil)
        
        animateLabel(self.offLabel, toColor: (on ? whiteColor : darkGreyColor))
        animateLabel(self.onLabel, toColor: (on ? darkGreyColor : whiteColor))
        
        self.onButton.isEnabled = !self.onButton.isEnabled
        self.offButton.isEnabled = !self.offButton.isEnabled

    }
    
    fileprivate func animateLabel(_ label : UILabel!, toColor : UIColor){
      
        UIView.transition(with: label,
            duration: 0.4,
            options:[.curveEaseOut,.transitionCrossDissolve,.beginFromCurrentState],
            animations: { () -> Void in
                label.textColor = toColor
            },
            completion: nil)
    }
}
