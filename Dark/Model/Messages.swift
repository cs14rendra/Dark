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
    
    func getLastMessage(conRef: DatabaseReference,completion:@escaping (String,Bool)->()){
        let last = conRef.child("messages").queryLimited(toLast:1)
        let ref = conRef.child(DARKFirebaseNode.newMessage.rawValue)
        let currentUserUID = Auth.auth().currentUser?.uid
        
        last.observeSingleEvent(of:.childAdded) {   snapshot in
            if snapshot.exists(){
                let values = snapshot.value as! [String : String]
                var lastMessage = "NA"
                if let value = values["text"]{
                    lastMessage = value
                }else{
                    lastMessage = "Photo"
                }
                
                if let uid = currentUserUID{
                    let newmsgBadge = ref.child(uid)
                    MessageStatus.sharedInstanse.isItNewMessage(usernewMessageRef: newmsgBadge, completion: { (isRead) in
                        print("newMSG\(isRead)")
                        completion(lastMessage,isRead)
                    })
                }else {
                    completion(lastMessage, true)
                }
                
            }else{
                completion("",false)
            }
        }
    }
    
    func getAllMessagesofKey(messageRef :DatabaseReference,completion: @escaping (Dictionary<String,String>,String)->() ){
       
        let messageQuery = messageRef.queryLimited(toLast:25)
        messageQuery.observe(.childAdded, with: {(snapshot) -> Void in
             let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String>
            completion(messageData,key)
        })
    }
    
    func updatedImageMessageforKey(messageRef :DatabaseReference,completion: @escaping (Dictionary<String,String>,String)->() ){
        messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String>
            completion(messageData,key)
        })
    }
}
