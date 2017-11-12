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

class Conversation{
    private static let _sharedInstanse = Conversation()
    static var sharedInstanse : Conversation{
        return _sharedInstanse
    }
    var lastMessageText : String?
    
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
        var chats = [Chat]()
        ref.observe(.childAdded) { (snapshot) in
            if snapshot.exists(){
                let convID = snapshot.key as String
                let value = snapshot.value as! [String : Any]
                let timeStamp = value[MessageKey.timeStamp.rawValue] as! Int
                let recieverIDfromServer = value[MessageKey.recieverID.rawValue] as! String
                let chat = Chat(recieverIDfromServer: recieverIDfromServer, timeStamp: timeStamp, convID: convID)
                chats.append(chat)
                completion(chats)
            }
        }
    }
}
