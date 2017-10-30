//
//  UserData.swift
//  Dark
//
//  Created by surendra kumar on 10/19/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation

struct UserDataModel : Codable {
    var uid : String
    var name : String?
    var age  : Int?
    var iam : String?
    var InterestedIn : String?
    var profilePicURL : String?
    
    init(id : String, user: User?) {
        self.uid = id
        self.name = user?.name
        self.age = user?.age
        self.iam = user?.iam
        self.InterestedIn = user?.InterestedIn
        self.profilePicURL = user?.profilePicURL
    }
}

