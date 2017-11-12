//
//  DetailViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/5/17.
//  Copyright © 2017 weza. All rights reserved.


import UIKit
import FirebaseAuth
import SkyFloatingLabelTextField
import LGButton
import SwiftKeychainWrapper

private enum ControllerSegueIdentifire : String{
    case showDetail
}
class DetailViewController: UIViewController {
    
    @IBOutlet var dark: UILabel!
    @IBOutlet var existing: UIButton!
    @IBOutlet var signIn: LGButton!
    @IBOutlet var color: GradientView!
    @IBOutlet var content: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var password: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var email: SkyFloatingLabelTextFieldWithIcon!
    
    var  handle : AuthStateDidChangeListenerHandle?
    var activeTextField : UITextField?
    
    private let keyWrapper = KeychainWrapper.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // EMAIL
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardshowed), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillhide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        self.hideKeyboardGuesture()
        self.addForgotPassBUtton()
        self.email.transform = CGAffineTransform(translationX: -self.view.frame.width, y:00)
        self.password.transform = CGAffineTransform(translationX: -self.view.frame.width, y:00)
        self.signIn.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.size.height)
        self.dark.alpha = 0.0
        self.existing.alpha = 0.0

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
            self.signIn.transform = .identity
        }, completion: nil)
        //
        UIView.animate(withDuration: 2.5, delay: 1.0, options: [.curveEaseInOut], animations: {
            self.dark.alpha = 1.0
        }, completion: nil)
        UIView.animate(withDuration: 2.5, delay: 1, options: [.curveEaseInOut], animations: {
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
    
    @IBAction func back(sender : UIButton){
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func okButton(_ sender: Any) {
        guard let email = email.text, let password = password.text, email != "", password != "" else  {
            self.showAlert(title: "Error!", message: "Enter Email and Password", buttonText: "OK")
            return
        }
        signIn.isLoading = true
        // Sign In
        // TODO : SAVE KEYCHAIN
        LoginOrSignUpEmail.sharedInstanse.loginUser(email: email, password: password) { error in
            guard error == nil else {
                self.handleAuthError(error: error!)
                return
                
            }
            self.signIn.isLoading = false
            self.performSegue(withIdentifier: ControllerSegueIdentifire.showDetail.rawValue, sender: self)
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

    func addForgotPassBUtton(){
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named : DARKImage.question.rawValue), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.frame = CGRect(x: password.frame.size.width - 25, y: 5, width: 25, height: 25)
        button.tintColor = UIColor.white.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        password.rightView = button
        password.rightViewMode = .always
    }
    
    @objc func forgotPassword(){
        var textfield : UITextField?
        let alert = UIAlertController(title: "Forgot Password?", message: "Enter email to reset password", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Email"
            textfield = textField
        })
        let done = UIAlertAction(title: "OK", style:.default, handler: { action in
            if let field = textfield{
                if let  email = field.text {
                    LoginOrSignUpEmail.sharedInstanse.resetPassword(email: email, completion: { error in
                        guard error == nil else {return}
                        self.showAlert(title: "Alert!", message: "Reset link have been sent to \(email)", buttonText: "OK")
                    })
                }
            }
        })
        let cancle = UIAlertAction(title: "Cancle", style: .destructive, handler: nil)
        alert.addAction(cancle)
        alert.addAction(done)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension DetailViewController : UITextFieldDelegate {
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
}
