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
import UserNotifications
import FirebaseMessaging

private let reuseIdentifier = "Cell"
private let tabName = "NearBy"
private let itemperRow : CGFloat = 3.0

private enum ControllerSegue : String {
    case celltochat
}

class UserViewController: UIViewController, IndicatorInfoProvider {
    
    //PROPERTY
    @IBOutlet var mycollecion: UICollectionView!
   
    //CONSTANTS
    
    private let sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private let locationManager = CLLocationManager()
    private let activity : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    private let manager = APIManager.sharedInstanse
    
    // VARIABLES
    var geoFire : GeoFire!
    var allKeysWithinRange : [String] = [String]()
    var userData : [UserDataModel?] = [UserDataModel?]()
    var refreshControll : UIRefreshControl?
    var handleListener : AuthStateDidChangeListenerHandle?
    var uid = Auth.auth().currentUser?.uid
    var userlocation : CLLocation?
    var geofire : GeoFire!
    var isqueriedDetalis : Bool = false
    
   
    
    // ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPulltoRefresh()
        UserDefaults.standard.set(true, forKey: Preferences.logIn.rawValue)
        geoFire = REF_GEOFIRE
        self.locationManager.startUpdatingLocation()
        self.configureActivity()
  }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        Auth.auth().currentUser?.getIDToken(completion: { token, error in
            guard error != nil else {return}
            if let errorCode = AuthErrorCode(rawValue: error!._code){
                switch errorCode {
                case .userTokenExpired :
                    self.showAlert(title: "Error!", message: "User need to login again", buttonText: "OK")
                    self.resetApp()
               case .userDisabled :
                    self.showAlert(title: "Error!", message: "User Account Disabled", buttonText: "OK")
                    self.resetApp()
                default : break
                    
                }
            }
        })
     }

    // Custom Method
    
    func configureActivity(){
        activity.center = CGPoint(x: self.view.center.x, y: self.view.center.y - (self.view.bounds.size.height/4))
        activity.color = UIColor.gray
        self.view.insertSubview(activity, at: 1)
        activity.hidesWhenStopped = true
        activity.startAnimating()
    }
    
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
      self.loadUsersData()
      refreshControll?.endRefreshing()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabName)
    }
   
    func loadUsersData(){
        self.manager.queryUsers(forCurrentuserUID: self.uid!, userlocation: self.userlocation!, completion: { users in
            self.userData = users
            DispatchQueue.main.async {
                self.mycollecion.reloadData()
                self.activity.isAnimating ? self.activity.stopAnimating():nil
            }
            
        })
    }
    
    // Overide Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ControllerSegue.celltochat.rawValue {
            if let index = self.mycollecion.indexPathsForSelectedItems?.first{
                let dest = segue.destination.childViewControllers.first as! UserDetailsViewController
                dest.userInfo = self.userData[index.item]
            }
        }
    }
}


extension UserViewController : UICollectionViewDataSource{
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.userData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        cell.settingImage.isHidden = true
        cell.backgroundColor = UIColor.darkGray
        let user = self.userData[indexPath.item]
        cell.eachUser = user
        return cell
    }
}

extension UserViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: ControllerSegue.celltochat.rawValue, sender: self)
        
    }
}

extension UserViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = ( itemperRow + 1) * sectionInset.left
        let availablewidth = self.view.frame.width - padding
        let widthPerItem : CGFloat = availablewidth / itemperRow
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
        // Automatic collectionView refresh is not Avaiable to users
        // User need to refresh Collection by pulling it down whenever location change
        if self.isqueriedDetalis == false {
            self.manager.updateLocation(forUserId: self.uid!, location: self.userlocation!)
             self.isqueriedDetalis = true
            self.loadUsersData()
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.showAlert(title: "Error!", message: "Unable to find location", buttonText: "OK")
    }
}


