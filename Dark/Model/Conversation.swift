//
//  Conversation.swift
//  Dark
//
//  Created by surendra kumar on 11/12/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class Chat{
    var recieverIDfromServer : String
    var timeStamp : Int
    var convID : String
    var lastMessage : String?
    var isNewMessage : Bool?
    
    init(recieverID : String,timeStamp: Int,convID: String) {
        self.recieverIDfromServer = recieverID
        self.timeStamp = timeStamp
        self.convID = convID
    }
}

class Conversation{
    private static let _sharedInstanse = Conversation()
    static var sharedInstanse : Conversation{
        return _sharedInstanse
    }
    func setNewConversation(recieverHandle : DatabaseReference, senderHandle: DatabaseReference,senderChatData :ChatMetaData,recieverChatData : ChatMetaData) throws{
        
        let encoder = JSONEncoder()
        let temp1 = try encoder.encode(senderChatData)
        let object1 = try JSONSerialization.jsonObject(with: temp1, options: .mutableContainers)
        senderHandle.setValue(object1)
        // for Reciever
        let temp2 = try encoder.encode(recieverChatData)
        let object2 = try JSONSerialization.jsonObject(with: temp2, options: .mutableContainers)
        recieverHandle.setValue(object2)
    }
    
    func showConversation(ref: DatabaseReference,completion: @escaping ([Chat])->()){
        ref.observe(.value) { (snapshot) in
            if snapshot.exists(){
                var chats = [Chat]()
                let operationGroup = DispatchGroup()
                for item in snapshot.children{
                    let snap = item as! DataSnapshot
                    let convID = snap.key as String
                    let value = snap.value as! [String : Any]
                    let timeStamp = value[MessageKey.timeStamp.rawValue] as! Int
                    let recieverIDfromServer = value[MessageKey.recieverID.rawValue] as! String
                    let chat = Chat(recieverID: recieverIDfromServer, timeStamp: timeStamp, convID: convID)
                    chats.append(chat)
                    let messageRef  = REF.child("Chat").child(convID)
                    operationGroup.enter()
                    Messages().getLastMessage(conRef: messageRef, completion: { lastMessage,isNewMessage in
                        chat.lastMessage = lastMessage
                        chat.isNewMessage = isNewMessage
                        operationGroup.leave()
                    })
                    operationGroup.notify(queue: .main, execute: {
                        completion(chats)
                    })
                }
                
            }
        }
    }
}
