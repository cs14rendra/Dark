//
//  UserCell.swift
//  Dark
//
//  Created by surendra kumar on 10/6/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

protocol UsercellDelegate : class {
    func didGetUserOnlineStatus(status : Bool)
}

private let onlineImage : UIImage = UIImage(named: DARKImage.online.rawValue)!
private let offlineImage: UIImage = UIImage(named: DARKImage.offline.rawValue)!

class UserCell: UICollectionViewCell {
    
    
    @IBOutlet var set: UIImageView!
    @IBOutlet var image: UIImageView!
    @IBOutlet var age: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var onlineStatus: UIImageView!
    weak var delegate : UsercellDelegate?
    private lazy var onlineStausREF = REF_USERSTATUS
    var handle : FirebaseHandle?
    
    var eachUser : UserDataModel?{
        didSet{
            updateCell()
        }
    }
    
    override func prepareForReuse() {
          self.image.image = nil
          self.name.text = nil
          self.age.text = nil
          self.set.image = nil
          self.onlineStatus.image = offlineImage
          self.onlineStatus.isHidden = false
        if let handler = self.handle{
            self.onlineStausREF.child((self.eachUser?.uid)!).removeObserver(withHandle: handler)
        }
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
        if self.eachUser?.uid == Auth.auth().currentUser?.uid {
            self.set.image = UIImage(named: DARKImage.setting.rawValue)
        }
        self.loadImage()
        self.setuserOnlineStatus()
    }
    
    func loadImage(){
        if let urltSring = eachUser?.profilePicURL, urltSring != "", let url = URL(string :urltSring) {
            ImageCache.sharedInstanse.loadimage(atURL: url, completion: { [weak self] img in
                if let image = img {
                    DispatchQueue.main.async {
                        self?.image.image = image
                    }
                }else{
                    DispatchQueue.main.async {
                        self?.image.image = UIImage(named: DARKImage.blank.rawValue)
                    }
                }
            })
        }else{
            self.image.image = UIImage(named: DARKImage.blank.rawValue)
        }
    }
    
    func setuserOnlineStatus(){
        guard self.eachUser?.uid != Auth.auth().currentUser?.uid else {
            self.onlineStatus.isHidden = true
            return
        }
        handle = onlineStausREF.child((self.eachUser?.uid)!).observe(DataEventType.value, with: { [weak self] snapshot in
            if snapshot.exists(){
                if snapshot.childrenCount == 1 {
                    self?.onlineStatus.image = offlineImage
                }else{
                    self?.onlineStatus.image = onlineImage
                }
            }else{
                // say offline
            }
        })
    }
}
