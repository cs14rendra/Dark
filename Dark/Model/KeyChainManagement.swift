//
//  KeyChainManagement.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class KeyChainManagment{
    
    private static let _sharedInstanse = KeyChainManagment()
    static var sharedInstanse : KeyChainManagment{
        return _sharedInstanse
    }
    let manager = KeychainWrapper.standard
    func setEmailandPassWord(email : String,password: String){
        manager.set(email, forKey: PrefKeychain.Email.rawValue)
        manager.set(password, forKey: PrefKeychain.Password.rawValue)
    }
    
    func setTwitterAuthTokenAndSecrete(token : String,secrete: String){
        manager.set(token, forKey: PrefKeychain.TwitterAuthToken.rawValue)
        manager.set(secrete, forKey: PrefKeychain.TwitterAuthSecrete.rawValue)
    }
    
    func setfaceBookAccessToken(accessToken : String){
        manager.set(accessToken, forKey: PrefKeychain.FacebookAccessToken.rawValue)
    }
    
    func setGoogleIDandAccesToken(ID : String, accessToken : String ){
        manager.set(ID, forKey: PrefKeychain.GoogleIdToken.rawValue)
        manager.set(accessToken, forKey: PrefKeychain.GoogleAccessToken.rawValue)
    }
    
    // Getter
    func getEmailandPassWord(completion:( NSCoding?,NSCoding?)->()){
        let email = manager.object(forKey: PrefKeychain.Email.rawValue)
        let pass = manager.object(forKey: PrefKeychain.Password.rawValue)
        completion(email,pass)
    }
    
    func getTwtterAuthTokenandSecrete(completion:( NSCoding?,NSCoding?)->()){
        let authToken = manager.object(forKey: PrefKeychain.TwitterAuthToken.rawValue)
        let authSecrete = manager.object(forKey: PrefKeychain.TwitterAuthSecrete.rawValue)
        completion(authToken,authSecrete)
    }
    
    func getFacebookAccessToken(completion:( NSCoding?)->()){
        let accessToken = manager.object(forKey: PrefKeychain.FacebookAccessToken.rawValue)
        completion(accessToken)
    }
    
    func getGoogleIDandAccesToken(completion:( NSCoding?,NSCoding?)->()){
        let googleID = manager.object(forKey: PrefKeychain.GoogleIdToken.rawValue)
        let AccessToken  = manager.object(forKey: PrefKeychain.GoogleAccessToken.rawValue)
        completion(googleID, AccessToken)
    }
}


