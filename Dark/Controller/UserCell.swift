//
//  UserCell.swift
//  Dark
//
//  Created by surendra kumar on 10/6/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import SDWebImage

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
    }
    
    func loadImage(){
       
        if let imageLink = eachUser?.profilePicURL{
            let url = URL(string: imageLink)
                self.image.sd_setImage(with: url , placeholderImage: UIImage(named:"blank"), options:.continueInBackground, progress: nil, completed: nil)
            
        }else{
            self.image.sd_setImage(with: nil , placeholderImage: UIImage(named:"blank"), options:.continueInBackground, progress: nil, completed: nil)
        }
    }

//
//    func requestIndivisualData(){
//        let location = eachUser?.locationDictonary
//        var uid : String?
//        //var userlocation : CLLocation?
//        let isLoadedOnce = eachUser?.isLoaded
//        for l in location! {
//            uid = l.key
//           // userlocation = l.value as? CLLocation
//        }
//        guard isLoadedOnce == false else {return}
//
//        userRef.child(uid!).child("userInformation").observeSingleEvent(of: .value) { (snapshot) in
//            // Initially not exist
//            if snapshot.exists() {
//                let value = snapshot.value  as! [String : Any]
//                let age = value["age"] as! NSNumber
//                self.age.text = String(describing: age)
//                self.eachUser?.isLoaded = true
//             }else{
//                self.age.text = ""
//            }
//        }
//
//    }
}
