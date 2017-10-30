//
//  UserCell.swift
//  Dark
//
//  Created by surendra kumar on 10/6/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth

class UserCell: UICollectionViewCell {
    
    @IBOutlet var settingImage: UIImageView!
    @IBOutlet var image: UIImageView!
    @IBOutlet var age: UILabel!
    @IBOutlet var name: UILabel!
    
    var eachUser : UserDataModel? {
        didSet{
            updateCell()
        }
    }
    
    override func prepareForReuse() {
          self.image.image = nil
          self.name.text = nil
          self.age.text = nil
        self.settingImage.isHidden = true
    }
    
    func updateCell(){
        if let name = eachUser?.name{
            self.name.text = name
        }
        if let timeInterval  = eachUser?.age{
            let date = Date(timeIntervalSince1970: TimeInterval(timeInterval))
            let year : Int = date.yearBetweenDate(startDate: date, endDate: Date())
            self.age.text = String(year)
           
        }
        self.loadImage()
        if self.eachUser?.uid == Auth.auth().currentUser?.uid {
            self.settingImage.isHidden = false
        }
    }
    
    func loadImage(){
       if let imageLink = eachUser?.profilePicURL{
            let url = URL(string: imageLink)
                self.image.sd_setImage(with: url , placeholderImage: UIImage(named:DARKImage.blank.rawValue), options:.continueInBackground, progress: nil, completed: nil)
            
        }else{
            self.image.sd_setImage(with: nil , placeholderImage: UIImage(named:DARKImage.blank.rawValue), options:.continueInBackground, progress: nil, completed: nil)
        }
    }

}
