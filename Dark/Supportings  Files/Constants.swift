//
//  Constants.swift
//  Dark
//
//  Created by surendra kumar on 10/9/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import UIKit

// Firebase:
let REF : DatabaseReference = Database.database().reference()
let REF_USER    = REF.child("users")
let REF_STORAGE = Storage.storage().reference(forURL: "gs://dark-780c5.appspot.com")
let REF_CHANNEL = REF.child("Channels")
let REF_CHAT    = REF.child("Chat")
let REF_USERSTATUS = REF.child("UserStatus")

// Color :
let DARKPINK = GMColor.pinkA400Color()

//Twitter

let TWITTERKEY = "zhP5rll2JCyIc2CokSAfjsWn7"
let TWITTERSECRETE  = "KGj166ifXcAeiVQoIF1NiGPaWMM76kyAMYHtTynx3yG6dUeAhm"
