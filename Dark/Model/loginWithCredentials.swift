//
//  loginWithCredentials.swift
//  Dark
//
//  Created by surendra kumar on 11/10/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKCoreKit

class loginWithCredentials {
    private  static  var _shared  = loginWithCredentials()
    static var shared : loginWithCredentials{
        return  _shared
    }
    
    func login(credentials : AuthCredential, completion: @escaping (Error?) -> ()){
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            guard error == nil else {
                completion(error)
                return}
            
            let uid = user?.uid
            guard uid != nil else {
                completion(error)
                return
            }
            
            REF_USER.child(uid!).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    completion(nil)
                }else{
                    self.requestFacebookGraphAPI()
                }
            }
        })
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
}
