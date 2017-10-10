//
//  MessageViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import  JSQMessagesViewController
import Firebase

class MessageViewController: JSQMessagesViewController {
    
    var recieverID : String?
    var convID : String?
   
    private lazy var messageRef: DatabaseReference = ref.child("Chat") .child("\(String(describing: convID!))").child("messages")
    var isRunOneTime : Bool = false
    private var handle: DatabaseHandle?
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
  var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let lb = UIButton(frame: CGRect(x: 10, y: 30, width: 100, height: 45))
        lb.setTitle("back", for: .normal)
        lb.setTitleColor(UIColor.blue, for: .normal)
        lb.addTarget(self, action: #selector(targetbutton), for: .touchUpInside)
        self.view.insertSubview(lb, at: 1)
        
        // Method
        self.InitialiseConversationID()
        finishReceivingMessage()
        self.observeMessages()
    }
    
    @objc func targetbutton(){
        self.dismiss(animated: true, completion: nil)
    }
    func InitialiseConversationID(){
        guard convID == nil else {return}
        let senderID5 = String(senderId.characters.prefix(5))
        let recieverID5 = String(recieverID!.characters.prefix(5))
        if (senderID5 > recieverID5){
            self.convID = senderID5 + recieverID5
        }else{
            self.convID = recieverID5 + senderID5
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        }else{
            return incomingBubbleImageView
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        if !isRunOneTime{
            let userchatref = ref.child("users").child(senderId).child("userchatList").child(self.convID!)
            userchatref.setValue(ServerValue.timestamp())
            self.isRunOneTime = true
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("Select From Gallery")
    }
    
    private func observeMessages() {
       
        // 1.
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        handle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    
}
