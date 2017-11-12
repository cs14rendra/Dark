//
//  LogOut.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKLoginKit
import TwitterKit
import GoogleSignIn

class LogOut{
    
    func firebaseLogout() throws{
        try  Auth.auth().signOut()
    }
    
    func FacebookLogout(){
        if let _ = FBSDKAccessToken.current(){
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrent(nil)
            FBSDKProfile.setCurrent(nil)
        }
    }
    
    func TwitterLogout(){
        let sessionstore = Twitter.sharedInstance().sessionStore
        if let userID = sessionstore.session()?.userID {
            sessionstore.logOutUserID(userID)
        }
    }
    
    func GoogleLogout(){
        if GIDSignIn.sharedInstance().hasAuthInKeychain(){
            GIDSignIn.sharedInstance().signOut()
        }
    }
}
