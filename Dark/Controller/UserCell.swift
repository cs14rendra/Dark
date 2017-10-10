//
//  UserCell.swift
//  Dark
//
//  Created by surendra kumar on 10/6/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit

class UserCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var age: UILabel!
    
    var eachUser : userData? {
        didSet{
            updateCell()
        }
    }
    func updateCell(){
        self.requestIndivisualData()
    }
    
   
    func requestIndivisualData(){
        let location = eachUser?.locationDictonary
        var uid : String?
        var userlocation : CLLocation?
        let isLoadedOnce = eachUser?.isLoaded
        for l in location! {
            uid = l.key
            userlocation = l.value as? CLLocation
        }
        guard isLoadedOnce == false else {return}
        let userQuery = userRef.child(uid!).child("userInformation").observeSingleEvent(of: .value) { (snapshot) in
            // Initially not exist
            if snapshot.exists() {
                let value = snapshot.value  as! [String : Any]
                let age = value["age"] as! NSNumber
                print("USER AGE: \(age)")
                self.age.text = String(describing: age)
                self.eachUser?.isLoaded = true
             }else{
                self.age.text = ""
            }
        }
        
    }
}
