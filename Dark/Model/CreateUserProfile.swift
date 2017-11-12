//
//  CreateUserProfile.swift
//  Dark
//
//  Created by surendra kumar on 11/10/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import Firebase

class UserProfile{
    
    private  static  var _shared  = UserProfile()
    static var shared :UserProfile{
        return  _shared
    }
    
    func createProfile(foruser userUID : String, user : User, completion : @escaping (Error?, DatabaseReference? )->()) throws{
        let object = try DARKCoder.sharedInstanse.encode(user: user)
        REF_USER.child(userUID).child(DARKFirebaseNode.userInformation.rawValue).setValue(object){ error,ref  in
              completion(error,ref)
        }
    }
}
