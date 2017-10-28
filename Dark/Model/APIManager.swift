//
//  Locationdata.swift
//  Dark
//
//  Created by surendra kumar on 10/18/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import Firebase
//
//class APIManager {
//    
//    func queryUsers(){
//        var temp : [String] = [String]()
//        let circleQuery = geoFire.query(at: self.userlocation, withRadius: 10)
//        circleQuery?.observe(.keyEntered, with: { (key, location) in
//            temp.append(key!)
//            
//        })
//        
//        circleQuery?.observeReady({
//            self.allKeysWithinRange = temp
//            self.mycollecion.collectionViewLayout.invalidateLayout()
//            self.getUsersDetalis()
//        })
//    }
//    
//    
//    
//    func getUsersDetalis() -> UserDataModel{
//        var isAllValueLoadedTracker  = [Bool]()
//        var data = [UserDataModel]()
//        for key in allKeysWithinRange {
//            userRef.child(key).child("userInformation").observeSingleEvent(of: .value) { (snapshot) in
//                
//                if snapshot.exists(){
//                    let response = snapshot.value as! [String : Any]
//                    let uid = key
//                    let name = response[UserEnum.name.rawValue] as! String
//                    let age = response[UserEnum.age.rawValue] as! NSNumber
//                    let iam = response[UserEnum.iam.rawValue] as! String
//                    let InterestedIn = response[UserEnum.InterestedIn.rawValue] as! String
//                    let picURL = response[UserEnum.profilePicURL.rawValue] as! String
//                    let user = UserDataModel(uid: uid, name: name, age: age as? Int, iam: iam, InterestedIn: InterestedIn, profilePicURL: picURL)
//                    print("SURI :\(age)")
//                    //Insert currrent user at first position
//                    if key == self.uid{
//                        data.insert(user, at: 0)
//                    }else{
//                        data.append(user)
//                    }
//                    isAllValueLoadedTracker.append(true)
//                }else{
//                    isAllValueLoadedTracker.append(true)
//                    data.append(UserDataModel(uid: key, name: nil, age: nil, iam: nil, InterestedIn: nil, profilePicURL: nil))
//                }
//            }
//        }
//        DispatchQueue(label: "waitforAllOperationtoFinished").async {
//            while(isAllValueLoadedTracker.count < self.allKeysWithinRange.count){
//            }
////            DispatchQueue.main.async {
//////                if self.activity.isAnimating {
//////                    self.activity.stopAnimating()
//////                }
////                self.userData = data
////                //self.mycollecion.reloadData()
////            }
//        }
//    }
//    
//}

