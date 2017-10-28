//
//  ViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/5/17.
//  Copyright © 2017 weza. All rights reserved.

import UIKit
import FirebaseAuth
import SkyFloatingLabelTextField
import LGButton
import DatePickerDialog
import SwiftDate

class ViewController: UIViewController {

   
    @IBOutlet var gender: CustomSwitch!
    @IBOutlet var birthday: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var color: GradientView!
    @IBOutlet var content: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var email: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var password: SkyFloatingLabelTextFieldWithIcon!
    var  handle : AuthStateDidChangeListenerHandle?
    var activeTextField : UITextField?
    
   
    // defaults user value
    var genderType : String = Gender.male.rawValue
    var userBirthDay : NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gender.delegate = self
        // Email
        email.iconFont = UIFont(name: "FontAwesome", size: 25)
        email.iconText = "\u{f007}"
        email.iconMarginLeft = 10.0
        email.iconMarginBottom = 5.0
        email.iconColor = UIColor.white.withAlphaComponent(0.3)
        // PASS
        password.iconFont = UIFont(name: "FontAwesome", size: 25)
        password.iconText = "\u{f023}"
        password.iconMarginLeft = 10.0
        password.iconMarginBottom = 5.0
        password.iconColor = UIColor.white.withAlphaComponent(0.3)
        // Birthday
        birthday.iconFont = UIFont(name: "FontAwesome", size: 25)
        birthday.iconText = "\u{f1fd}"
        birthday.iconMarginLeft = 10.0
        birthday.iconMarginBottom = 5.0
        birthday.iconColor = UIColor.white.withAlphaComponent(0.3)
        birthday.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didBirthDaytapped)))
        birthday.isUserInteractionEnabled = true
        
        // Notificationns
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardshowed), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillhide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        self.hideKeyboardGuesture()
        }

    @objc func didBirthDaytapped(){
        print("tapped")
        DatePickerDialog().show("BirthDay", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: (Date() - 13.years), minimumDate: (Date() - 99.years), maximumDate: (Date() - 13.years), datePickerMode: .date) { date in
            if let newdate = date {
                self.userBirthDay = newdate.timeIntervalSince1970 as NSNumber
                self.birthday.text = newdate.dateStringFromDate()
            
            }
        }
        
    }
    @objc func keyboardshowed(notifivation : Notification){
        if  let textField = activeTextField , let keyboardSize = (notifivation.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
            
            var aRect = self.view.frame
            print("\(aRect.size.height) : \(keyboardSize.size.height)")
            aRect.size.height =  aRect.size.height - keyboardSize.size.height
            if(!aRect.contains(textField.frame.origin)){
                self.scrollView.scrollRectToVisible(textField.frame, animated: true)
                
            }
        
        }
    }
    
    @objc func keyboardwillhide(notification : Notification){
        let contentInset = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
        
      
    }
    
    @IBOutlet var signbutton: LGButton!
    @IBAction func okButton(_ sender: Any) {
        guard let emailValue = email.text, !emailValue.isEmpty  else  {
            self.showAlert(title: "Error!", message: "Enter Email", buttonText: "OK")
            return }
        
        guard let passwordValue = password.text, !passwordValue.isEmpty else  {
            self.showAlert(title: "Error!", message: "Enter Password", buttonText: "OK")
            return }
        guard let birthday = self.userBirthDay, birthday != 0 else {
            self.showAlert(title: "Error!", message: "Enter Birthday", buttonText: "OK")
            return
        }
        
        signbutton.isLoading = true
         //Sign UP
        Auth.auth().createUser(withEmail: emailValue, password: passwordValue) { (user, error) in
            self.signbutton.isLoading = false
            guard error == nil else {
                self.handleAuthError(error: error!)
                return
            }
            self.createUserProfile()
            self.performSegue(withIdentifier: "show", sender: self)
          }
    }
    
    func createUserProfile(){
        // Everythings is checked Before
        let user = User(name: "", age: userBirthDay as! Int, iam: self.genderType, InterestedIn: "", profilePicURL: "")
        let encoder = JSONEncoder()
        do{
            let userDetalis = try encoder.encode(user)
            let object = try JSONSerialization.jsonObject(with: userDetalis, options: .mutableContainers)
            ref.child("users").child((Auth.auth().currentUser?.uid)!).child("userInformation").setValue(object)
        }catch{
            print(error.localizedDescription)
        }
    }

    func hideKeyboardGuesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(done))
        self.color.isUserInteractionEnabled = true
        self.color.addGestureRecognizer(tap)
    }
    @objc func done(){
    self.view.endEditing(true)
   
    }
}

extension ViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextTextField = textField.superview?.viewWithTag(textField.tag+1) as? UITextField{
             nextTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 99{
            
            self.showAlert(title: "active", message: "ok", buttonText: "ok")
            return false
        }
        return true
    }
}

extension ViewController : CustomSwitchDelegate{
    func customSwitchValueDidChange(value: Bool) {
        if value == true {
            self.genderType = Gender.female.rawValue
        }else{
            self.genderType = Gender.male.rawValue
        }
    }
    
    
}
