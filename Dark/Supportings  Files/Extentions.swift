//
//  Global.swift
//  Dark
//
//  Created by surendra kumar on 10/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

extension UIViewController{
    public func showAlert(title : String, message: String, buttonText: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    public func handleAuthError(error : Error){
        if let errorCode =  AuthErrorCode(rawValue: error._code){
            
            switch errorCode{
            case .accountExistsWithDifferentCredential ,.emailAlreadyInUse:
                self.showAlert(title: "Error!", message: "Email Already in Use", buttonText: "OK")
            case .invalidEmail :
                self.showAlert(title: "Error!", message: "InValid Email", buttonText: "OK")
                
            case .wrongPassword :
                self.showAlert(title: "Error!", message: "Wrong Password", buttonText: "OK")
                
            case .userNotFound :
                self.showAlert(title: "Error!", message: "Account does not exist", buttonText: "OK")
            case .networkError :
                self.showAlert(title: "Error!", message: "Network connection problem", buttonText: "OK")
            case .userDisabled :
                self.showAlert(title: "Error!", message: "Account has been blocked", buttonText: "OK")
            case .weakPassword :
                self.showAlert(title: "Error!", message: "Weak Password", buttonText: "OK")
            default:
                self.showAlert(title: "Error!", message: "Problem in Signing...", buttonText: "OK")
            }
        }
    }
    
    func resetApp(){
        // UserDEfaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Preferences.logIn.rawValue)
        defaults.removeObject(forKey: Preferences.Gender.rawValue)
        defaults.removeObject(forKey: Preferences.InterestedIn.rawValue)
        defaults.synchronize()
        
        // Keychain
        let wrapper = KeychainWrapper.standard
        _ = wrapper.removeAllKeys()
        
        // MainScreen
        
        let singUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signUp")
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window?.rootViewController = singUpViewController
        
    }
}

extension UILabel {
    func addIconToLabel(imageName: String, labelText: String, bounds_x: Double, bounds_y: Double, boundsWidth: Double, boundsHeight: Double) {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: imageName)
        attachment.bounds = CGRect(x: bounds_x, y: bounds_y, width: boundsWidth, height: boundsHeight)
        let attachmentStr = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: "")
        string.append(attachmentStr)
        let string2 = NSMutableAttributedString(string: labelText)
        string.append(string2)
        self.attributedText = string
    }
}

extension Date{
    
    func dateStringFromDate() -> String{
        let formatter = DateFormatter()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: self)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current,year: components.year  ,month : components.month,day : components.day, weekday : components.weekday)
        
        let yearNumber = newComponents.year!
        
        let dayNumber  = newComponents.day!
        let dayString = String(describing: dayNumber)
        
        let monthNumber = newComponents.month!
        let monthString = formatter.shortMonthSymbols[(monthNumber-1) % 12]
        
        let fomrmattedDateString : String = " \(dayString) \(monthString), \(yearNumber)"
        

        return fomrmattedDateString
    }
    
    func yearBetweenDate(startDate : Date , endDate : Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.dateComponents([.year], from: startDate, to: endDate)
        return component.year! as Int
        
    }
}

