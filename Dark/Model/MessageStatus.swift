
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
import Firebase

class MessageStatus{
    private static let _sharedInstanse = MessageStatus()
    static var sharedInstanse : MessageStatus{
        return _sharedInstanse
    }
 
    func setNewMessageBadgeforReciever(newMessgeBadgeRef: DatabaseReference,data : Any){
        newMessgeBadgeRef.setValue(data)
    }
    
    func isItNewMessage(usernewMessageRef:DatabaseReference, completion:@escaping (Bool)->()){
        usernewMessageRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if snapshot.exists(){
                let val = snapshot.value as! Bool
                print(print("TnewMSG\(val)"))
                completion(val)
            }else {
                completion(false)
            }
        }
    }
    
    func diduserReadMessage(havenewMessage : Bool,ref: DatabaseReference){
        ref.setValue(havenewMessage)
    }
    
    func isUserTyping(typingquery : DatabaseQuery,completion:@escaping (Int)->()){
        typingquery.observe(.value) { (snapshot) in
            let count = snapshot.childrenCount
            completion(Int(count))
        }
    }
}
