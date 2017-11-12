//
//  loginWithFacebook.swift
//  Dark
//
//  Created by surendra kumar on 11/10/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import  FirebaseAuth

class loginWithFacebook {
    private  static  var _shared  = loginWithFacebook()
    static var shared : loginWithFacebook{
        return  _shared
    }
    
    func login(){
        
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: nil, from: self) { result, error in
            guard error == nil else { return }
            let fbloginresult : FBSDKLoginManagerLoginResult = result!
            
            guard !fbloginresult.isCancelled else {return}
            guard let accessToken = FBSDKAccessToken.current().tokenString else {
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
            
            Auth.auth().signIn(with: <#T##AuthCredential#>, completion: <#T##AuthResultCallback?##AuthResultCallback?##(User?, Error?) -> Void#>)
            
        }
        
    }
}
