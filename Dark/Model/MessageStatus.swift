
//
//  MessageStatus.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class MessageStatus{
    private static let _sharedInstanse = MessageStatus()
    static var sharedInstanse : MessageStatus{
        return _sharedInstanse
    }
 
    func setNewMessageBadgeforReciever(newMessgeBadgeRef: DatabaseReference,data : Any){
        newMessgeBadgeRef.setValue(data)
    }
}
