//
//  UserToken.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserToken {
    private static let _sharedInstanse = UserToken ()
    static var sharedInstanse : UserToken {
        return _sharedInstanse
    }
    func getUserToken(foruser user : User?, completion : @escaping (String?, Error?)->()){
        user?.getIDToken(completion: { token, error in
            completion(token,error)
        })
    }
}
