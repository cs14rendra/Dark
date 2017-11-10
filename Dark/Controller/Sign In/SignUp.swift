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
    
    private let keyWrapper = KeychainWrapper.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
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
    
    override var prefersStatusBarHidden: Bool{
        return true
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
    
    @IBAction func facebook(_ sender: Any) {
        self.clearTextFieldsIfnotSignUpUsingEmail()
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: nil, from: self) { result, error in
            guard error == nil else { return }
            let fbloginresult : FBSDKLoginManagerLoginResult = result!
        
            guard !fbloginresult.isCancelled else {return}
            guard let accessToken = FBSDKAccessToken.current().tokenString else {
                self.showAlert(title: "Error", message: "Failed Facebook Authentication", buttonText: "OK")
                return
            }
            self.keyWrapper.set(accessToken, forKey: PrefKeychain.FacebookAccessToken.rawValue)
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken)
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                guard error == nil else {self.handleAuthError(error: error!);return}
                
                let uid = Auth.auth().currentUser?.uid
                guard uid != nil else {return}
                
                REF_USER.child(uid!).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists(){
                         self.performSegueTomainPage()
                    }else{
                        self.requestFacebookGraphAPI()
                    }
                }
            })

        }
        
    }
    
  
    
    @IBAction func twitter(_ sender: Any) {
        self.clearTextFieldsIfnotSignUpUsingEmail()
        Twitter.sharedInstance().logIn(with: self) { (session, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let accessToken = session?.authToken else {return}
            guard let accessSecrete = session?.authTokenSecret else {return}
            
            self.keyWrapper.set(accessToken, forKey: PrefKeychain.TwitterAuthToken.rawValue)
            self.keyWrapper.set(accessSecrete, forKey: PrefKeychain.TwitterAuthSecrete.rawValue)
            let credentials = TwitterAuthProvider.credential(withToken: accessToken, secret: accessSecrete)
            
            let twitterClient = TWTRAPIClient(userID: session?.userID)
            twitterClient.loadUser(withID: (session?.userID)!, completion: { (user, error) in
                guard error == nil else {return}
                self.url = user?.profileImageMiniURL
            })
            
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                guard error == nil else {
                    self.handleAuthError(error: error!)
                    return
                }
                let uid = Auth.auth().currentUser?.uid
                guard uid != nil else {return}
                
                REF_USER.child(uid!).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists(){
                        self.performSegueTomainPage()
                    }else{
                        self.openPopToAskBirthDayandGenderType()
                    }
                }
            })
            
        }
    }
    
    @IBAction func google(_ sender: Any) {
        self.clearTextFieldsIfnotSignUpUsingEmail()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func okButton(_ sender: Any) {
        
        guard let emailValue = email.text, !emailValue.isEmpty  else  {
            self.showAlert(title: "Error!", message: "Enter Email", buttonText: "OK")
            return }
        
        guard let passwordValue = password.text, !passwordValue.isEmpty else  {
            self.showAlert(title: "Error!", message: "Enter Password", buttonText: "OK")
            return }
      
        signbutton.isLoading = true
         //Sign UP
        Auth.auth().createUser(withEmail: emailValue, password: passwordValue) { (user, error) in
            self.signbutton.isLoading = false
            guard error == nil else {
                self.handleAuthError(error: error!)
                return
            }
            self.openPopToAskBirthDayandGenderType()
         }
    }
    
    func requestFacebookGraphAPI(){
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"gender,picture,first_name"]).start(){connection,result,error in
            
            if  let value = result as? [String : AnyObject]{
                self.name = value["first_name"] as? String
                self.genderType = value["gender"] as? String
                if let a  = value["picture"]{
                    if let b = a["data"] as? [String:AnyObject]{
                        self.url = b["url"] as? String
                    }
                }
                DatePickerDialog().show("BirthDay", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: (Date() - 13.years), minimumDate: (Date() - 99.years), maximumDate: (Date() - 13.years), datePickerMode: .date) { date in
                    if let newdate = date {
                        let timeinterval  = newdate.timeIntervalSince1970
                        self.userBirthDay = timeinterval.rounded()
                        self.createUserProfileandPerformSegue()
                    }
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
        let user = User(name: self.name, age: age, iam: gender, InterestedIn: nil, profilePicURL: self.url)
       do{
             let object = try DARKCoder.sharedInstanse.encode(user: user)
        REF_USER.child((Auth.auth().currentUser?.uid)!).child(DARKFirebaseNode.userInformation.rawValue).setValue(object)
        
             if let pass = self.password.text{
                if  pass != "" {
                    keyWrapper.set(pass, forKey: PrefKeychain.Password.rawValue)
                }
            }
            self.performSegueTomainPage()
        }catch{
            print(error.localizedDescription)
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
        return true
    }
}

extension ViewController : PopDelegate{
    func passgenderValue(gender: String?) {
        self.genderType = gender
        self.createUserProfileandPerformSegue()
    }
}


extension ViewController : GIDSignInDelegate, GIDSignInUIDelegate{
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {return}
        guard let authentication = user.authentication else {return }
        
        let credentials = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credentials) { (user, error) in
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
            
            self.keyWrapper.set(authentication.idToken, forKey: PrefKeychain.GoogleIdToken.rawValue)
            self.keyWrapper.set(authentication.accessToken, forKey: PrefKeychain.GoogleAccessToken.rawValue)
            
            REF_USER.child(uid!).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    self.performSegueTomainPage()
                }else{
                    self.openPopToAskBirthDayandGenderType()
                }
            }
        }
    }
}
