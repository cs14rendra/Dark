//
//  LoginUsingTwitter.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import TwitterKit
import FirebaseAuth

class LoginUsingTwitter{
    private static let _sharedInstanse = LoginUsingTwitter()
    static var sharedInstanse : LoginUsingTwitter{
        return _sharedInstanse
    }
    
    func login(context : UIViewController, onSuccess : @escaping (String?,AuthCredential)->(), onFailure : @escaping (Error?)->()){
        
        Twitter.sharedInstance().logIn(with: context) { (session, error) in
            guard error == nil else {
                onFailure(error)
                return
            }
            guard let accessToken = session?.authToken else {
                onFailure(error)
                return}
            guard let accessSecrete = session?.authTokenSecret else {
                onFailure(error)
                return}
            
//            self.keyWrapper.set(accessToken, forKey: PrefKeychain.TwitterAuthToken.rawValue)
//            self.keyWrapper.set(accessSecrete, forKey: PrefKeychain.TwitterAuthSecrete.rawValue)
            let credentials = TwitterAuthProvider.credential(withToken: accessToken, secret: accessSecrete)
            let uid = session?.userID
            onSuccess(uid, credentials)
        }
    }
    
    func getDetalisTwitterClientAPI(id : String, onSuccess:@escaping (String?)->(), onFailure:@escaping (Error?)->()){
        let twitterClient = TWTRAPIClient(userID: id)
        twitterClient.loadUser(withID: id, completion: { (user, error) in
            guard error == nil else {
                onFailure(error)
                return}
            onSuccess(user?.profileImageMiniURL)
        })
    }
}
