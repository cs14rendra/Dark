//
//  UserProfile.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation

class UserProfile {
    
    private static let _sharedInstanse = UserProfile()
    
    static var sharedInstanse : UserProfile{
        return _sharedInstanse
    }
    func CreateUserProfile(id : String , user : DARKUser, completion: @escaping (Error?)->())throws{
        let object = try DARKCoder.sharedInstanse.encode(user: user)
        REF_USER.child(id).child(DARKFirebaseNode.userInformation.rawValue).setValue(object){
            error , ref in
            completion(error)
        }
    }
}
