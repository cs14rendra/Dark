//
//  LoginUsingFacebook.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class LoginUsingFacebook {
    private static let _sharedInstanse = LoginUsingFacebook()
    static var sharedInstanse : LoginUsingFacebook{
        return _sharedInstanse
    }
    
    func login(context : UIViewController, onSuccess : @escaping (String)->(), onFailure : @escaping (Error?)->()){
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: nil, from: context) { result, error in
            guard error == nil else {
            onFailure(error)
            return }
            let fbloginresult : FBSDKLoginManagerLoginResult = result!
            
            guard !fbloginresult.isCancelled else {
                onFailure(error)
                return
            }
            guard let accessToken = FBSDKAccessToken.current().tokenString else {
                onFailure(error)
                return
            }
            KeyChainManagment.sharedInstanse.setfaceBookAccessToken(accessToken: accessToken)
            onSuccess(accessToken)
        }
    }
    
    func getDetalisFromGrapAPI(completion:@escaping (String?,String?,String?)->()){
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"gender,picture,first_name"]).start(){connection,result,error in
    
        var name : String?
        var gender : String?
        var picURL : String?
        if  let value = result as? [String : AnyObject]{
            name = value["first_name"] as? String
            gender = value["gender"] as? String
                if let a  = value["picture"]{
                        if let b = a["data"] as? [String:AnyObject]{
                                picURL = b["url"] as? String
                        }
                }
            }
            completion(name,gender,picURL)
        }
     }
}
