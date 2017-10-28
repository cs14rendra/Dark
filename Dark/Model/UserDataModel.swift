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
}

enum UserEnum : String{
    case uid
    case name
    case age
    case iam
    case InterestedIn
    case profilePicURL
}
