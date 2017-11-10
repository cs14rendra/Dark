//
//  ChatTableViewCell.swift
//  Dark
//
//  Created by surendra kumar on 10/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class ChatTableViewCell: UITableViewCell {

    @IBOutlet var profImage: UIImageView!
    @IBOutlet var chatText: UILabel!
    let UID = Auth.auth().currentUser?.uid

    private lazy var isNewMessageRef : DatabaseReference =  REF_CHAT.child("\(String(describing: cellconvID!))").child(DARKFirebaseNode.newMessage.rawValue)
    
    var cellconvID : String?{
        didSet{
            getLastMessage()
        }
    }
    
    var recieverID : String? {
        didSet{
            upDateCell()
        }
    }

    override func prepareForReuse() {
        self.profImage.image = nil
        self.chatText.text = nil
    }

    func upDateCell(){
        let imageRef : DatabaseReference = REF_USER.child(recieverID!).child(DARKFirebaseNode.userInformation.rawValue).child(DARKFirebaseNode.profilePicURL.rawValue)
        imageRef.observe(.value) { [weak self] snapshot in
            if snapshot.exists(){
                let imageLink = snapshot.value as! String
                self?.setImage(imageLink: imageLink)
            }else{
            print("NOT EXIST")
                self?.profImage.image = UIImage(named: DARKImage.blank.rawValue)
            }
        }
    }
    
    func setImage(imageLink : String){
        if imageLink != "", let url = URL(string :imageLink) {
            ImageCache.sharedInstanse.loadimage(atURL: url, completion: { [weak self] img in
                if let image = img {
                    DispatchQueue.main.async {
                        self?.profImage.image  = image
                    }
                }else{
                    DispatchQueue.main.async {
                        self?.profImage.image  = UIImage(named: DARKImage.blank.rawValue)
                    }
                }
            })
        }else{
            self.profImage.image = UIImage(named: DARKImage.blank.rawValue)
        }
        
    }
   
    func getLastMessage(){
        let refChat = REF.child("Chat").child(self.cellconvID!).child("messages").queryLimited(toLast:1)
        refChat.observe(.childAdded) { [weak self]  snapshot in
            if snapshot.exists(){
                let chatData  = snapshot.value as! [String:String]
                let sender = chatData["senderId"]
                self?.isNewMessageRef.child((self?.UID)!).observe(.value, with: { [weak self] snapshot in
                    if snapshot.exists(){
                        let isExist = snapshot.value as! Bool
                        
                        if let msg = chatData["text"] {                            guard sender != Auth.auth().currentUser?.uid else {
                                self?.chatText.text = msg
                                return}
                            self?.chatText.text = msg
                            if isExist{
                                self?.chatText.font = self?.chatText.font.withSize(22)
                                self?.chatText.textColor = DARKPINK
                            }
                        }else{
                            guard sender != Auth.auth().currentUser?.uid else {
                                self?.chatText.text = "Photo Sent!"
                                return}
                          
                            self?.chatText.text = "Photo Recieved!"
                            if isExist {
                                self?.chatText.font = self?.chatText.font.withSize(22)
                                self?.chatText.textColor = DARKPINK
                            }
                        }
                    }
                })
                
            }
        }
    }
    
    deinit {
        REF.removeAllObservers()
    }
}
