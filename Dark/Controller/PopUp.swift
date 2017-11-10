//
//  AgePickerViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/31/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import FirebaseAuth
import DatePickerDialog
import SwiftDate

protocol PopDelegate {
    func passgenderValue(gender: String?)
}

class PopUp: UIViewController {

    var delegate : PopDelegate?
    @IBOutlet var myswitch: CustomSwitch!
    @IBOutlet var mainView: UIView!

    var gender : String? = Gender.male.rawValue
    private var userBirthday: NSNumber?
    
    override func viewDidLoad() {
        self.myswitch.delegate = self
        super.viewDidLoad()
        self.mainView.layer.cornerRadius = 2.0
        self.mainView.layer.masksToBounds = true
        
   }
    @IBAction func ok(sender: Any) {
         self.delegate?.passgenderValue(gender: self.gender)
        self.dismiss(animated: true, completion: nil)
    }
 
}

extension PopUp : CustomSwitchDelegate{
    
    func customSwitchValueDidChange(value: Bool) {
        if value == true {
            self.gender = Gender.female.rawValue
        }else{
            self.gender = Gender.male.rawValue
        }
    }
}
