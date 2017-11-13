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
import FBSDKLoginKit
import TwitterKit
import GoogleSignIn
import SwiftKeychainWrapper

private enum ControllerSegue : String{
    case show
    case mainpage
}

private let storyBoardName = "Main"
private let popUpID = "popUP"

class ViewController: UIViewController {

    @IBOutlet var existing: UIButton!
    @IBOutlet var beclassical: UILabelX!
    @IBOutlet var gbuttton: UIButton!
    @IBOutlet var signUpView: UIView!
    @IBOutlet var color: GradientView!
    @IBOutlet var content: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var email: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var password: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var signbutton: LGButton!
 
    var handle : AuthStateDidChangeListenerHandle?
    var activeTextField : UITextField?
    var name : String?
    var url: String?
    var genderType : String?
    var userBirthDay : Double?
    
    // Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Notificationns
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardshowed), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillhide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        self.hideKeyboardGuesture()
        self.email.transform = CGAffineTransform(translationX: -self.view.frame.width, y:00)
        self.password.transform = CGAffineTransform(translationX: -self.view.frame.width, y:00)
        self.beclassical.alpha = 0.0
        self.existing.alpha = 0.0
        self.signbutton.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.size.height)
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: [.curveEaseInOut], animations: {
            self.email.transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.6, options: [.curveEaseInOut], animations: {
            self.password.transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 1.1, usingSpringWithDamping: 0.88, initialSpringVelocity: 0.1, options: [.curveEaseInOut], animations: {
            self.signbutton.transform = .identity
        }, completion: nil)
        //
        UIView.animate(withDuration: 3.5, delay: 1.1, options: [.curveEaseInOut], animations: {
            self.beclassical.alpha = 1.0
        }, completion: nil)
        UIView.animate(withDuration: 3.5, delay: 2, options: [.curveEaseInOut], animations: {
            self.existing.alpha = 1.0
        }, completion: nil)
    }
    // MARK : Action
    @IBAction func facebook(_ sender: Any) {
        self.clearTextFieldsIfnotSignUpUsingEmail()
        LoginUsingFacebook.sharedInstanse.login(context: self, onSuccess: { (accessToken) in
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken)
            UserWithCr.sharedInstanse.SignIn(with: credentials, completion: { user, error in
                guard error == nil else {
                    self.handleAuthError(error: error!)
                    return
                }
                let UID = Auth.auth().currentUser?.uid
                UserWithCr.sharedInstanse.isUserExist(withUID: UID!, completion: { (isExist) in
                    if isExist{
                        self.performSegueTomainPage()
                    }else{
                        self.requestFacebookGraphAPI()
                    }
                })
            })
        }) { error in
            self.showAlert(title: "Error!", message: "Unable to Authenticate with facebook", buttonText: "OK")
        }
    }
    
  
    
    @IBAction func twitter(_ sender: Any) {
        self.clearTextFieldsIfnotSignUpUsingEmail()
        LoginUsingTwitter.sharedInstanse.login(context: self, onSuccess: { uid, credentials in
            if let id = uid {
                LoginUsingTwitter.sharedInstanse.getDetalisTwitterClientAPI(id: id, onSuccess: { picURL in
                    self.url = picURL
                }, onFailure: { (error) in })
            }
            UserWithCr.sharedInstanse.SignIn(with: credentials, completion: { (user,error) in
                guard error == nil else {
                    self.handleAuthError(error: error!)
                    return}
                let uid = Auth.auth().currentUser?.uid
                guard uid != nil else {return}
                UserWithCr.sharedInstanse.isUserExist(withUID: uid!, completion: { (isExist) in
                    if isExist{
                        self.performSegueTomainPage()
                    }else{
                        self.openPopToAskBirthDayandGenderType()
                    }
                })
                
            })
            
        }) { error in
            self.showAlert(title: "Error", message: "unable to Authenticate using twitter", buttonText: "OK")
        }
    }
    
    @IBAction func google(_ sender: Any) {
        self.clearTextFieldsIfnotSignUpUsingEmail()
         LoginUsingGoogle.sharedInstanse.login()
         NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onGoogleNotification(notification:)), name: LoginUsingGoogle.notificationName, object: nil)
    }
    
    @IBAction func okButton(_ sender: Any) {
        guard let emailValue = email.text, !emailValue.isEmpty  else  {
            self.showAlert(title: "Error!", message: "Enter Email", buttonText: "OK")
            return }
        guard let passwordValue = password.text, !passwordValue.isEmpty else  {
            self.showAlert(title: "Error!", message: "Enter Password", buttonText: "OK")
            return }
        signbutton.isLoading = true
        LoginOrSignUpEmail.sharedInstanse.createUser(email: emailValue, password: passwordValue) { (error) in
            self.signbutton.isLoading = false
            guard error == nil else {
                self.handleAuthError(error: error!)
                return
            }
            self.openPopToAskBirthDayandGenderType()
        }
    }
   
    // MARK : @Objc
    @objc func onGoogleNotification(notification : Notification){
        let userInfo = notification.userInfo as! [String :Any]
        guard let _ = userInfo["error"]  else {
            return
        }
        let user : GIDGoogleUser? =  userInfo["user"] as? GIDGoogleUser
        guard let authentication = user?.authentication else {return}
        KeyChainManagment.sharedInstanse.setGoogleIDandAccesToken(ID: authentication.idToken, accessToken: authentication.accessToken)
        let credentials = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        UserWithCr.sharedInstanse.SignIn(with: credentials) { user, error in
            guard error == nil else {
                self.handleAuthError(error: error!)
                return
            }
            self.name = user?.displayName
            if let urlString  =  user?.photoURL {
                self.url = String(describing: urlString)
            }
            let uid = Auth.auth().currentUser?.uid
            guard uid != nil else {return}
            UserWithCr.sharedInstanse.isUserExist(withUID: uid!, completion: { (isExist) in
                if isExist{
                    self.performSegueTomainPage()
                }else{
                    self.openPopToAskBirthDayandGenderType()
                }
            })
        }
    }
    
    @objc func keyboardshowed(notifivation : Notification){
        if  let textField = activeTextField , let keyboardSize = (notifivation.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
            
            var aRect = self.view.frame
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
    
    // MARK : Custom Method
    func requestFacebookGraphAPI(){
        LoginUsingFacebook.sharedInstanse.getDetalisFromGrapAPI { (name, gender, picURL) in
            self.name = name
            self.genderType = gender
            self.url = picURL
            DatePickerDialog().show("BirthDay", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: (Date() - 13.years), minimumDate: (Date() - 99.years), maximumDate: (Date() - 13.years), datePickerMode: .date) { date in
                if let newdate = date {
                    let timeinterval  = newdate.timeIntervalSince1970
                    self.userBirthDay = timeinterval.rounded()
                    self.createUserProfileandPerformSegue()
                }
            }
        }
    }
    
    func openPopToAskBirthDayandGenderType(){
        DatePickerDialog().show("BirthDay", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: (Date() - 13.years), minimumDate: (Date() - 99.years), maximumDate: (Date() - 13.years), datePickerMode: .date) { date in
            if let newdate = date {
                let timeinterval  = newdate.timeIntervalSince1970
                self.userBirthDay = timeinterval.rounded()
                let pop = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: popUpID) as? PopUp
                pop?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                pop?.modalTransitionStyle   =  UIModalTransitionStyle.crossDissolve
                pop?.delegate = self
                self.present(pop!, animated: true, completion: nil)
                
            }
        }
    }

 func createUserProfileandPerformSegue(){
        guard let age = self.userBirthDay , let gender = self.genderType else {return}
        print(age)
        let user = DARKUser(name: self.name, age: age, iam: gender, InterestedIn: nil, profilePicURL: self.url)
        if let currentUID = Auth.auth().currentUser?.uid{
            do {
                try UserProfile.sharedInstanse.CreateUserProfile(id: currentUID, user: user, completion: { (error) in
                    guard error == nil else {
                        self.handleAuthError(error: error!)
                        return
                    }
                    self.performSegueTomainPage()
                })
                
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func performSegueTomainPage(){
        let mainController = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: ControllerSegue.mainpage.rawValue)
        UIApplication.shared.keyWindow?.rootViewController = mainController
    }

    func hideKeyboardGuesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(done))
        self.color.isUserInteractionEnabled = true
        self.color.addGestureRecognizer(tap)
    }
    
    @objc func done(){
    self.view.endEditing(true)
    }
    
    func clearTextFieldsIfnotSignUpUsingEmail(){
        self.email.text = ""
        self.password.text = ""
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        REF.removeAllObservers()
    }
    
    
    // MARK : Ovrriden Method
    override var prefersStatusBarHidden: Bool{
        return true
    }
}

// Extension
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
        return true
    }
}

extension ViewController : PopDelegate{
    func passgenderValue(gender: String?) {
        self.genderType = gender
        self.createUserProfileandPerformSegue()
    }
}


