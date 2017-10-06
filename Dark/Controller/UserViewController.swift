//
//  UserViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/6/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class UserViewController: UIViewController {
    
    @IBOutlet var mycollecion: UICollectionView!
    private let itemperRow : CGFloat = 3
    let numberofItem  = 14
    let sectionInset = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    var geoFire : GeoFire!
    var locationData : [[String : CLLocation]] = [[String : CLLocation]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        geoFire = GeoFire(firebaseRef: ref.child("location"))
        queryUsers()
        print(locationData)
    }
    
    func queryUsers(){
        let circleQuery = geoFire.query(at: CLLocation(latitude: 12, longitude: 17), withRadius: 1000)
        circleQuery?.observe(.keyEntered, with: { (key, location) in
            //print("USERLOCATION IS :\(location)")
            let data : [String: CLLocation] = [key! : location!]
            self.locationData.append(data)
            
        })
        circleQuery?.observeReady({
            print("All DATA : \(self.locationData)")
            self.mycollecion.reloadData()
        })
       
    }
}


extension UserViewController : UICollectionViewDataSource{
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.locationData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCell
       
        cell.backgroundColor = UIColor.red
        
        return cell
    }
}

extension UserViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = ( itemperRow + 1) * sectionInset.left
        let availablewidth = self.view.frame.width - padding
        let widthPerItem = availablewidth / itemperRow
        return CGSize(width: widthPerItem, height: widthPerItem)
        
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return sectionInset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInset.left
    }
}
