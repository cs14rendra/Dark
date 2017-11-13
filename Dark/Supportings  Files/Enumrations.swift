//
//  Enumrations.swift
//  Dark
//
//  Created by surendra kumar on 10/29/17.
//  Copyright © 2017 weza. All rights reserved.
//


enum Gender : String{
    case male
    case female
}

enum DARKFirebaseNode : String{
    case userInformation
    case userchatList
    case location
    case Chat
    case name
    case profilePicURL
    case messages
    case isUserTyping
    case iam
    case newMessage
}

enum DARKImage : String{
    case blank
    case chat
    case question
    case tuser
    case tmap
    case online
    case offline
    case setting
}

// Preferences :
enum Preferences : String {
    case logIn
    case Gender
    case InterestedIn
    case Distance
}

enum PrefKeychain : String{
    case Email
    case Password
    case FacebookAccessToken
    case TwitterAuthToken
    case TwitterAuthSecrete
    case GoogleIdToken
    case GoogleAccessToken
}

