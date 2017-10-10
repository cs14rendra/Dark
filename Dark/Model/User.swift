
//
//  File.swift
//  Dark
//
//  Created by surendra kumar on 10/6/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation

class User {
    var name : String
    var age  : Int
    var iam : String
    var InterestedIn : String
    var profilePicURL : String
    
    init(name : String , age : Int, iam : String , InterestedIn: String,profilePicURL: String) {
        self.name = name
        self.age =  age
        self.iam = iam
        self.InterestedIn = InterestedIn
        self.profilePicURL = profilePicURL
    }
    
    func userDictonary (user : User) -> [String : Any] {
        return ["name" : user.name,
                "age" : user.age,
                "iam" : user.iam,
                "intestedIn" : user.InterestedIn,
                "profilePicURL" : user.profilePicURL
                ]
    }
}
