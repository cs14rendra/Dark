//
//  Locationdata.swift
//  Dark
//
//  Created by surendra kumar on 10/18/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import Firebase

protocol APIManagerDelegate : class {
    func didLoadMapData(mapData : [MapData])
}
class APIManager {
    static let sharedInstanse = APIManager()
    private var geofire : GeoFire!
    private var allKeysWithinRange = [String]()
    private let currentUserPositionInCollectionView = 0
    weak var delegate  : APIManagerDelegate?
    
    func queryUsers(forCurrentuserUID uid: String, onUserRef ref : DatabaseReference, intheRadious radious : Double , userlocation : CLLocation, completion : @escaping (_ users:[UserDataModel])-> ()){
        
        var temp : [String] = [String]()
        var mapdata : [MapData] = [MapData]()
        geofire = GeoFire(firebaseRef: ref)
        let circleQuery = geofire?.query(at: userlocation, withRadius: radious)
        
        circleQuery?.observe(.keyEntered, with: { (key, location) in
            temp.append(key!)
            mapdata.append(MapData(key: key, location: location))
        })
        
        circleQuery?.observeReady({
            circleQuery?.removeAllObservers()
            if !temp.contains(uid){ temp.insert(uid, at: 0) }
            self.allKeysWithinRange = temp
            self.delegate?.didLoadMapData(mapData: mapdata)
            self.getUsersDetalis(forCurrentuserUID: uid ,forkeys: self.allKeysWithinRange, completion:{ users in
                completion(users)
            })
        })
    }
    
    func updateLocation(forUserId id : String, forRef ref : DatabaseReference, location : CLLocation){
        geofire = GeoFire(firebaseRef: ref)
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
                        data.append(UserDataModel(id: key, user: nil))
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
            REF_USER.removeAllObservers()
            completion(data)
        }
        
    }
}

