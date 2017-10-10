//
//  UserViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/6/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import XLPagerTabStrip

class userData{
    var locationDictonary : [String: Any]?
    var isLoaded : Bool?
    
    init(location : [String: Any], isload : Bool) {
        self.locationDictonary = location
        self.isLoaded = isload
    }
}

private let reuseIdentifier = "Cell"

class UserViewController: UIViewController, IndicatorInfoProvider {
    
    //PROPERTY
    @IBOutlet var mycollecion: UICollectionView!
    @IBOutlet var activity: UIActivityIndicatorView!
    
    //CONSTANTS
    private let itemperRow : CGFloat = 1
    let sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
    let locationManager = CLLocationManager()
  
    // VARIABLES
    var geoFire : GeoFire!
    var locationData : [userData?] = [userData?]()
    var refreshControll : UIRefreshControl?
    var handleListener : AuthStateDidChangeListenerHandle?
    var uid : String?
    var userlocation : CLLocation?
    var geofire : GeoFire!
    var isqueriedDetalis : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPulltoRefresh()
        geoFire = GeoFire(firebaseRef: ref.child("location"))
        self.locationManager.startUpdatingLocation()
        print(locationData)
        
    }
    
    // ViewController Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.view.layoutIfNeeded()
        handleListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            guard user !=  nil else {return}
            self.uid = user?.uid
            //self.fetchlocalUserInfo(onUid: self.uid!)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handleListener = self.handleListener else {return}
        Auth.auth().removeStateDidChangeListener(handleListener)
    }
    
    // Custom Method
    func requestAuthorization(){
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            return
        case .denied, .restricted :
            self.showEventsAcessDeniedAlert()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func showEventsAcessDeniedAlert(){
        let alert = UIAlertController(title: "location", message: "turn on location", preferredStyle: .alert)
        let settingdAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let appsettings = NSURL(string: UIApplicationOpenSettingsURLString){
                UIApplication.shared.open(appsettings as URL, options: [:], completionHandler: nil)
            }
        }
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(settingdAction)
        alert.addAction(cancleAction)
        var top = UIApplication.shared.keyWindow?.rootViewController
        while  top?.presentedViewController != nil{
            top = top?.presentedViewController
            }
        top?.present(alert, animated: true, completion: nil)
    }
    
    func addPulltoRefresh(){
        refreshControll = UIRefreshControl()
        refreshControll?.bounds = CGRect(x: refreshControll!.bounds.origin.x, y: refreshControll!.bounds.origin.y+50, width: refreshControll!.bounds.size.width, height: refreshControll!.bounds.size.height)
        refreshControll?.tintColor = UIColor.gray
        refreshControll?.addTarget(self, action: #selector(UserViewController.pulltoRefreshTarget), for: .valueChanged)
        self.mycollecion.addSubview(refreshControll!)
        self.mycollecion.alwaysBounceVertical = true
       
    }
    
    @objc func pulltoRefreshTarget(){
      self.isqueriedDetalis = false
      refreshControll?.beginRefreshing()
        if !self.locationData.isEmpty {
            self.locationData.removeAll()
            //print(self.locationData.count)
        }
      self.queryUsers()
      refreshControll?.endRefreshing()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "NearBy")
    }

    func fetchlocalUserInfo(onUid id : String){
        ref.child("users").child(self.uid!).observeSingleEvent(of: .value) { (snapshot) in
            //let value = snapshot.value as? [String : Any]
        }
    }
    
    func queryUsers(){
        var temp : [userData?] = [userData?]()
        
        let circleQuery = geoFire.query(at: self.userlocation, withRadius: 1000)
        circleQuery?.observe(.keyEntered, with: { (key, location) in
            //print("USERLOCATION IS :\(location)")
            let locationdata : [String: CLLocation] = [key! : location!]
            let userdata = userData(location: locationdata, isload: false)
            temp.append(userdata)
        })

        circleQuery?.observeReady({
            self.locationData = temp
            self.mycollecion.reloadData()
            self.mycollecion.collectionViewLayout.invalidateLayout()
        })
    }
    
    func updateLocation(forId id : String, location : CLLocation){
        geofire = GeoFire(firebaseRef: ref.child("location"))
        geofire.setLocation(location, forKey: uid)
    }
    
    // Overide Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "celltochat" {
            if let index = self.mycollecion.indexPathsForSelectedItems?.first{
                let dest = segue.destination as! MessageViewController
                
                dest.senderDisplayName = "VALUE TO SET"
                dest.senderId = self.uid
                let userData = self.locationData[index.item]
                let location = userData?.locationDictonary
                for l in location! {
                       dest.recieverID = l.key
                
                }
            }
        }
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
            let userData = self.locationData[indexPath.item]
//            let location = userData.locationDictonary
//            for l in location! {
//                cell.eachUserUid = l.key
//            }
            cell.eachUser = userData
        
        return cell
    }
    
    
}

extension UserViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard uid != nil else {
            return
        }
        if indexPath.item == 0 {
            self.performSegue(withIdentifier: "userdetails", sender: self)
        }else{
        self.performSegue(withIdentifier: "celltochat", sender: self)
        }
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

extension UserViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userlocation = locations.first
        
        if self.isqueriedDetalis == false {
        self.updateLocation(forId: self.uid!, location: self.userlocation!)
        self.queryUsers()
        self.isqueriedDetalis = true
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
