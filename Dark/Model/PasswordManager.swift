//
//  PasswordManager.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth

class PasswordManager {
    
    func changePassword(user: User,email: String,password: String,newPassword:String, completion : @escaping (Error?)->()){
        var credentials : AuthCredential
        credentials = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credentials, completion: { error in
            guard error == nil else {
                completion(error)
                return
            }
            user.updatePassword(to: newPassword, completion: { error in
               completion(error)
            })
        })
    }

    func resetPassword(email : String,completion:@escaping (Error?)->()){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
}
