//
//  TouchID.swift
//  Dark
//
//  Created by surendra kumar on 11/2/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchID{
    public static let sharedInstanse = TouchID()
    let context = LAContext()
    
    private func canEvaluatePolicy() -> Bool{
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func suthenticateUser(){
        guard self.canEvaluatePolicy() else{return}
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sure to delete Account") { success, error in
            guard !success else {
                print(error?.localizedDescription)
                return
            }
            
        }
    }
}
