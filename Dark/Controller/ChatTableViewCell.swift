//
//  ChatTableViewCell.swift
//  Dark
//
//  Created by surendra kumar on 10/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage

class ChatTableViewCell: UITableViewCell {

    @IBOutlet var profImage: UIImageView!
    @IBOutlet var chatText: UILabel!
    
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
        imageRef.observe(.value) { snapshot in
            if snapshot.exists(){
                let imageLink = snapshot.value as! String
                self.setImage(imageLink: imageLink)
            }else{
            print("NOT EXIST")
                self.setBlankImage()
            }
        }
        REF_USER.child(recieverID!).child(DARKFirebaseNode.userInformation.rawValue).child(DARKFirebaseNode.name.rawValue).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let name = snapshot.value as! String
                self.chatText.text = name
            }
        }
        
    }
    
    func setImage(imageLink : String){
        guard imageLink != "" else {
            print("NO IMAGE LINK")
               self.setBlankImage()
            return
        }
        let url = URL(string: imageLink)
        self.profImage.sd_setImage(with: url, placeholderImage: UIImage(named:DARKImage.blank.rawValue), options: .continueInBackground, completed: nil)
    }
    
    func setBlankImage(){
        self.profImage.sd_setImage(with: nil, placeholderImage: UIImage(named:DARKImage.blank.rawValue), options:.continueInBackground, progress: nil, completed: nil)
    }
}
