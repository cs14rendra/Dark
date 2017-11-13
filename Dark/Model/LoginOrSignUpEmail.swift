//
//  Login+SignUpEmail.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth

class LoginOrSignUpEmail {
    
    private static let _sharedInstanse = LoginOrSignUpEmail()
    static var sharedInstanse : LoginOrSignUpEmail{
        return _sharedInstanse
    }
    
    
    func createUser(email : String, password: String,completion:@escaping (Error?)->()){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            KeyChainManagment.sharedInstanse.setEmailandPassWord(email: email, password: password)
           completion(error)
        }
    }
    
    func loginUser(email:String, password: String,completion:@escaping (Error?)->()){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            KeyChainManagment.sharedInstanse.setEmailandPassWord(email: email, password: password)
           completion(error)
        }
    }
    
}
