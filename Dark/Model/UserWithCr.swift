//
//  File.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

class UserWithCr {
    private static let _sharedInstanse = UserWithCr()
    static var sharedInstanse : UserWithCr{
        return _sharedInstanse
    }
    
    func SignIn(with credentials : AuthCredential, completion : @escaping (User?, Error?)->()){
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            guard error == nil else {                completion(user,error)
                return}
            
            let uid = Auth.auth().currentUser?.uid
            guard uid != nil else {
                completion(user,error)
                return}
            
           completion(user,nil)
        })
    }
    
    func isUserExist(withUID id : String , completion: @escaping (Bool)->()){
        REF_USER.child(id).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                completion(true)
                //self.performSegueTomainPage()
            }else{
                //self.requestFacebookGraphAPI()
                completion(false)
            }
        }
    }
    
    
}
