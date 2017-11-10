//
//  SettingsViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/29/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import TwitterKit
import GoogleSignIn
import SwiftKeychainWrapper
import LocalAuthentication

class SettingsViewController: UIViewController {
    
    var oldPass : UITextField?
    var newPass : UITextField?
    var confPass : UITextField?
    var userpPoviderID  : String?
    var password : UITextField?
    var distance : Int?

    let currentUser = Auth.auth().currentUser
    let wrapper = KeychainWrapper.standard
    let context = LAContext()
    
    
    @IBOutlet var distanceSlider: UISlider!
    @IBOutlet var disstanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Must have initail Value
        self.distance =  UserDefaults.standard.integer(forKey: Preferences.Distance.rawValue)
        self.disstanceLabel.text = "\(self.distance!)"
        self.distanceSlider.setValue(Float(self.distance!), animated: false)
    }

    @IBAction func logOut(_ sender: Any) {
      self.dismiss(animated: false, completion: nil)
        do{
            
            try self.logOut()
            self.resetApp()
        }catch{
           
            print(error.localizedDescription)
        }
    }
    @IBAction func changePass(_ sender: Any) {
        self.changepassWord()
    }
    
    @IBAction func deleteAcoount(_ sender: Any) {
        self.authenticateUser()
    }
    
    @IBAction func SliderValue(_ sender: UISlider) {
        self.distance = Int(exactly: sender.value.rounded())
        self.disstanceLabel.text = "= \(self.distance!)"
    }
    
    
    private func canEvaluatePolicy() -> Bool{
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser(){
        guard self.canEvaluatePolicy() else{
            self.deleteAccount()
            return}
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sure to delete Account") { success, error in
            
            guard success else {
                guard error != nil else {return}
                switch error! {
                case LAError.biometryNotAvailable : self.deleteAccount()
                case LAError.biometryNotEnrolled : self.deleteAccount()
                default : break
                }
                return}
            
            self.deleteAccount()
        }
    }
    
    deinit {
        if let distance = self.distance{
            UserDefaults.standard.set(distance, forKey: Preferences.Distance.rawValue)
        }
    }
}


// EXTENSION
extension SettingsViewController {
    func logOut() throws{
        
            try  Auth.auth().signOut()
            // Facebook
            if let _ = FBSDKAccessToken.current(){
                FBSDKLoginManager().logOut()
                FBSDKAccessToken.setCurrent(nil)
                FBSDKProfile.setCurrent(nil)
            }
            // Twitter
            let sessionstore = Twitter.sharedInstance().sessionStore
            if let userID = sessionstore.session()?.userID {
                sessionstore.logOutUserID(userID)
            }
            // Google
            if GIDSignIn.sharedInstance().hasAuthInKeychain(){
                GIDSignIn.sharedInstance().signOut()
            }
    }
}

extension SettingsViewController{
    func deleteAccount(){
        guard let user = currentUser else {return}
        for item in user.providerData{
            self.userpPoviderID = item.providerID
        }
        guard let id = self.userpPoviderID else {return}
        switch id {
        case "password"     : self.deleteAccountOFEmail()
        case "google.com"   : self.deleteAccountOfGoogle()
        case "facebook.com" : self.deleteAcoountOfFacebook()
        case "twitter.com"  : self.deleteAccountOfTwitter()
        default             : break
        }
    }
   
    func deleteAccountOFEmail(){
        let password = wrapper.string(forKey: PrefKeychain.Password.rawValue)
        
        guard password != nil else {
            self.showAlert(title: "Error!", message: "Developer Error 😂😂", buttonText: "OK")
            return
        }
        guard let email = currentUser?.email else {
            self.showAlert(title: "Error!", message: "Developer Error Email😂😂", buttonText: "OK")
            return
        }
        var credentials : AuthCredential
        credentials = EmailAuthProvider.credential(withEmail: email, password: password!)
        currentUser?.reauthenticate(with: credentials, completion: { error in
            guard error == nil else {
                self.handleAuthError(error: error!)
                return
            }
            // Delete User Data
            self.deleteCurrentUser()
        })
    }
    
    func deleteAccountOfGoogle(){
        let accessToken = wrapper.string(forKey: PrefKeychain.GoogleAccessToken.rawValue)
        let IdToken = wrapper.string(forKey: PrefKeychain.GoogleIdToken.rawValue)
        
        guard accessToken != nil, IdToken != nil else {
            self.showAlert(title: "Error!", message: "Developer Error 😂😂", buttonText: "OK")
            return
        }
        let credentials = GoogleAuthProvider.credential(withIDToken: IdToken!, accessToken: accessToken!)
        self.currentUser?.reauthenticate(with: credentials, completion: { error in
            guard error == nil else{
                self.handleAuthError(error: error!)
                return
            }
            self.deleteCurrentUser()
        })
    }
    func deleteAcoountOfFacebook(){
        let accessToken = wrapper.string(forKey: PrefKeychain.FacebookAccessToken.rawValue)
        guard accessToken != nil else {
            self.showAlert(title: "Error!", message: "Developer Error 😂😂", buttonText: "OK")
            return
        }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken!)
        self.currentUser?.reauthenticate(with: credentials, completion: { error in
            guard error == nil else{
                self.handleAuthError(error: error!)
                return
            }
            self.deleteCurrentUser()
        })
    }
    
    func deleteAccountOfTwitter(){
        let AuthToken = wrapper.string(forKey: PrefKeychain.TwitterAuthToken.rawValue)
        let AuthSecrete = wrapper.string(forKey: PrefKeychain.TwitterAuthSecrete.rawValue)
        
        guard AuthToken != nil, AuthSecrete != nil else {
            self.showAlert(title: "Error!", message: "Developer Error 😂😂", buttonText: "OK")
            return
        }
        let credentials = TwitterAuthProvider.credential(withToken: AuthToken!, secret: AuthSecrete!)
        self.currentUser?.reauthenticate(with: credentials, completion: { error in
            guard error == nil else{
                self.handleAuthError(error: error!)
                return
            }
            self.deleteCurrentUser()
        })
    }
}

extension SettingsViewController : UITextFieldDelegate{
    
    func changepassWord(){
        guard let user = currentUser else {return}
        for item in user.providerData{
            self.userpPoviderID = item.providerID
        }
        guard let id = self.userpPoviderID else {return}
        switch id {
        case "password":
            self.changeEmailPassword()
        default:
            self.showAlert(title: "Error!", message: "Password can be chang only if user sign In with Email ID", buttonText: "OK")
        }
    }

    func changeEmailPassword(){
        let alert = UIAlertController(title: "Change Password?", message: "Enter Password", preferredStyle: .alert)
        
        alert.addTextField { oldPassword in
            oldPassword.placeholder = "Old Password"
            oldPassword.isSecureTextEntry = true
            oldPassword.delegate = self
            oldPassword.tag = 0
            self.oldPass = oldPassword
            
        }
        alert.addTextField { newPassword in
            newPassword.placeholder = "New Password"
            newPassword.isSecureTextEntry = true
            newPassword.delegate = self
            newPassword.tag = 1
            self.newPass = newPassword
        }
        alert.addTextField { confPassword in
            confPassword.placeholder = "Confirm Password"
            confPassword.isSecureTextEntry = true
            confPassword.delegate = self
            confPassword.tag = 2
            self.confPass = confPassword
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.performChangeEmailPassword()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func performChangeEmailPassword(){
        guard let oldpasstext = self.oldPass?.text, oldpasstext != "" else {
            self.showAlert(title: "Error!", message: "Enter Old Password", buttonText: "OK")
            return
        }
        guard let newpasstext = self.newPass?.text, newpasstext != "" else {
            self.showAlert(title: "Error!", message: "Enter New Password", buttonText: "OK")
            return
        }
        guard let confpasstext = self.confPass?.text, confpasstext != "" else {
            self.showAlert(title: "Error!", message: "Enter Confirm Password", buttonText: "OK")
            return
        }
        guard newpasstext == confpasstext else {
            self.showAlert(title: "Error!", message: "New Password did Not Match ", buttonText: "OK")
            return
        }
        guard let email = currentUser?.email else {
            self.showAlert(title: "Error!", message: "No current User", buttonText: "OK ")
            return
        }
        
        var credentials : AuthCredential
        credentials = EmailAuthProvider.credential(withEmail: email, password: oldpasstext)
        currentUser?.reauthenticate(with: credentials, completion: { error in
            guard error == nil else {
                self.handleAuthError(error: error!)
                return
            }
            self.currentUser?.updatePassword(to: newpasstext, completion: { error in
                guard error == nil else {
                    self.handleAuthError(error: error!)
                    return
                }
                self.showAlert(title: "Successful", message: "Password Changed Successfully", buttonText: "OK")
            })
        })
    }
    
}

extension SettingsViewController{
    
    func deleteCurrentUser(){
        let defaults = UserDefaults.standard
        let gender = defaults.string(forKey: Preferences.Gender.rawValue)
        REF.child("location").child(gender!).child((self.currentUser?.uid)!).removeValue()
        REF_USER.child((self.currentUser?.uid)!).removeValue()
        self.currentUser?.delete(completion: { error in
            guard error == nil else {
                self.showAlert(title: "Error!", message: "Unable to delete Account. Try Again later.", buttonText: "OK")
                return
            }
            self.resetApp()
        })
    }
}
