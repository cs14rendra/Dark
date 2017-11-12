//
//  DeleteAccount.swift
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
import SwiftKeychainWrapper

class DeleteAccount{
     let wrapper = KeychainWrapper.standard
    
    func deleteAccountOFEmail(user: User,email : String, password: String,completion:@escaping (Error?)->()){
        let password = wrapper.string(forKey: PrefKeychain.Password.rawValue)
       
        var credentials : AuthCredential
        credentials = EmailAuthProvider.credential(withEmail: email, password: password!)
        user.reauthenticate(with: credentials, completion: { error in
            guard error == nil else {
                completion(error)
                return
            }
            // Delete User Data
            self.deleteCurrentUser(user: user, completion: { error in
                completion(error)
            })
            
        })
    }
    
    func deleteAccountOfGoogle(user: User,completion:@escaping (Error?)->()){
        let accessToken = wrapper.string(forKey: PrefKeychain.GoogleAccessToken.rawValue)
        let IdToken = wrapper.string(forKey: PrefKeychain.GoogleIdToken.rawValue)
        
        let credentials = GoogleAuthProvider.credential(withIDToken: IdToken!, accessToken: accessToken!)
        user.reauthenticate(with: credentials, completion: { error in
            guard error == nil else {
                completion(error)
                return
            }
            // Delete User Data
            self.deleteCurrentUser(user: user, completion: { error in
                completion(error)
            })
            
        })
    }
    func deleteAccountOfFacebook(user: User,completion:@escaping (Error?)->()){
        let accessToken = wrapper.string(forKey: PrefKeychain.FacebookAccessToken.rawValue)
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken!)
        user.reauthenticate(with: credentials, completion: { error in
            guard error == nil else {
                completion(error)
                return
            }
            // Delete User Data
            self.deleteCurrentUser(user: user, completion: { error in
                completion(error)
            })
            
        })
    }
    
    func deleteAccountOfTwitter(user: User,completion:@escaping (Error?)->()){
        let AuthToken = wrapper.string(forKey: PrefKeychain.TwitterAuthToken.rawValue)
        let AuthSecrete = wrapper.string(forKey: PrefKeychain.TwitterAuthSecrete.rawValue)
        let credentials = TwitterAuthProvider.credential(withToken: AuthToken!, secret: AuthSecrete!)
        user.reauthenticate(with: credentials, completion: { error in
            guard error == nil else {
                completion(error)
                return
            }
            // Delete User Data
            self.deleteCurrentUser(user: user, completion: { error in
                completion(error)
            })
          
        })
        
        
    }
    
    private func deleteCurrentUser(user: User,completion: @escaping (Error?)->()){
        let defaults = UserDefaults.standard
        let gender = defaults.string(forKey: Preferences.Gender.rawValue)
        REF.child("location").child(gender!).child(user.uid).removeValue()
        REF_USER.child(user.uid).removeValue()
        user.delete(completion: { error in
            completion(error)
        })
    }

}
