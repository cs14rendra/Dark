//
//  loginOrSignUsingEmail.swift
//  Dark
//
//  Created by surendra kumar on 11/10/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth
import SwiftKeychainWrapper

class loginOrSignUsingEmail {
    private  static  var _shared  = loginOrSignUsingEmail()
    static var shared : loginOrSignUsingEmail{
        return  _shared 
    }
    
    
    
    func SignUp(email: String, password: String,completion: @escaping (Error?)->()){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                completion(error)
                return }
            KeychainWrapper.standard.set(password, forKey: PrefKeychain.Password.rawValue)
            completion(nil)
            return
        }
    }
    
    func SignIn(email: String, password: String,completion: @escaping (Error?)->()){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
           guard error == nil else {
                completion(error)
                return
            }
            KeychainWrapper.standard.set(password, forKey: PrefKeychain.Password.rawValue)
            completion(nil)
            return
        }
    }
   
}
