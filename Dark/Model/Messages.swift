//
//  Messages.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class Messages{
    private static let _sharedInstanse = Messages()
    static var sharedInstanse : Messages{
        return _sharedInstanse
    }
    
    func createMessage(ref: DatabaseReference,message : Any){
        ref.setValue(message)
    }
    
    func getLastMessage(){
    
    }
    
}
