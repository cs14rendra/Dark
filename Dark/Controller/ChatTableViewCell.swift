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
    }

    func upDateCell(){
        
        
        let imageRef : DatabaseReference = userRef.child(recieverID!).child("userInformation")
        imageRef.observe(.value) { snapshot in
            if snapshot.exists(){
                let v = snapshot.value as! [String: Any]
                let imageLink = v["profilePicURL"] as! String
                self.setImage(imageLink: imageLink)
            }else{
            print("NOT EXIST")
                self.setBlankImage()
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
        self.profImage.sd_setImage(with: url, placeholderImage: UIImage(named:"blank"), options: .continueInBackground, completed: nil)
    }
    
    func setBlankImage(){
        self.profImage.sd_setImage(with: nil, placeholderImage: UIImage(named:"blank"), options:.continueInBackground, progress: nil, completed: nil)
    }
}
