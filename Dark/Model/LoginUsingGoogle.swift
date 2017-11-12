//
//  LoginUsingGoogle.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import GoogleSignIn

class LoginUsingGoogle : NSObject {
    static let notificationName = NSNotification.Name("loginNotif")
    private static let _sharedInstanse = LoginUsingGoogle()
    static var sharedInstanse : LoginUsingGoogle{
        return _sharedInstanse
    }
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func login(){
     GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {}
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {}
}

extension LoginUsingGoogle : GIDSignInUIDelegate, GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        NotificationCenter.default.post(name: LoginUsingGoogle.notificationName, object: nil, userInfo: ["user":user,"error":error])
        }
}


