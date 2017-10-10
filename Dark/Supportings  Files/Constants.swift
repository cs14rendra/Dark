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

let ref : DatabaseReference = Database.database().reference()
let userRef = ref.child("users")

let storageRef = Storage.storage().reference(forURL: "gs://dark-780c5.appspot.com")
