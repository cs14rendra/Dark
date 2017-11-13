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
    
    var chat : Chat?{
        didSet{
            upDateCell()
        }
    }
    
    override func prepareForReuse() {
        self.profImage.image = nil
        self.chatText.textColor = nil
        self.chatText.font = UIFont(name: "AvenirNext-Regular", size: 17)!
    }
    
    
    func upDateCell(){
        let imageRef : DatabaseReference = REF_USER.child((chat?.recieverIDfromServer)!).child(DARKFirebaseNode.userInformation.rawValue).child(DARKFirebaseNode.profilePicURL.rawValue)
        imageRef.observe(.value) {  snapshot in
            if snapshot.exists(){
                let imageLink = snapshot.value as! String
                self.setImage(imageLink: imageLink)
            }else{
                print("NOT EXIST")
                self.profImage.image = UIImage(named: DARKImage.blank.rawValue)
            }
        }
        setText()
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
    
    func setText(){
        self.chatText.text = chat?.lastMessage
        if let isNewMessage = chat?.isNewMessage{
            if isNewMessage{
                 self.chatText.textColor = DARKPINK
                 self.chatText.font  =  UIFont(name:"AvenirNext-DemiBold", size: 20.0)
            }else{
                self.chatText.textColor = UIColor.white
            }
        }else{
            self.chatText.textColor = UIColor.white
        }
    }
    
}
