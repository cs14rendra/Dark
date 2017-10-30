//
//  Locationdata.swift
//  Dark
//
//  Created by surendra kumar on 10/18/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import Firebase

class APIManager {
    static let sharedInstanse = APIManager()
    private var geofire = REF_GEOFIRE
    private var allKeysWithinRange = [String]()
    private let currentUserPositionInCollectionView = 0
    
    func queryUsers(forCurrentuserUID uid: String,  userlocation : CLLocation, completion : @escaping (_ users:[UserDataModel])-> ()){
        var temp : [String] = [String]()
        let circleQuery = geofire?.query(at: userlocation, withRadius: 10)
        circleQuery?.observe(.keyEntered, with: { (key, location) in
            temp.append(key!)
            
        })
        
        circleQuery?.observeReady({
            self.allKeysWithinRange = temp
            self.getUsersDetalis(forCurrentuserUID: uid ,forkeys: self.allKeysWithinRange, completion:{ users in
                completion(users)
            })
        })
    }
    
    func updateLocation(forUserId id : String, location : CLLocation){
        geofire = REF_GEOFIRE
        geofire?.setLocation(location, forKey: id)
    }
    
    private func getUsersDetalis(forCurrentuserUID currrentUserUID : String, forkeys keys : [String], completion : @escaping (_ users:[UserDataModel])-> ()){
        var isAllValueLoadedTracker  = [Bool]()
        var data = [UserDataModel]()
        
        for key in keys {
            REF_USER.child(key).child(DARKFirebaseNode.userInformation.rawValue).observeSingleEvent(of: .value) { (snapshot) in
                
                if snapshot.exists(){
                    do{
                        let coder = DARKCoder.sharedInstanse
                        let userData = try coder.decode(jsonDecodableObjectofTypeAny: snapshot.value!) // Non-null value 
                        let useruid = key
                        let user = UserDataModel(id: useruid, user: userData)
                        //Insert currrent user at first position
                        if useruid == currrentUserUID {
                            data.insert(user, at: self.currentUserPositionInCollectionView)
                        }else{
                            data.append(user)
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }else{
                    data.append(UserDataModel(id: key, user: nil))
                }
                isAllValueLoadedTracker.append(true)
            }
        }
        DispatchQueue(label: "waitforAllOperationtoFinished").async {
            while(isAllValueLoadedTracker.count < self.allKeysWithinRange.count){
            }
            completion(data)
        }
        
    }
}

