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
import ReachabilitySwift

private let reuseIdentifier = "Cell"
private let tabName = "NearBy"
private let itemperRow : CGFloat = 3.0
private let bannerHeight : CGFloat = 40

private enum ControllerSegue : String {
    case celltochat
}

class UserViewController: UIViewController, IndicatorInfoProvider {
    
    //PROPERTY
    @IBOutlet var mycollecion: UICollectionView!
   
    //CONSTANTS
    
    private let sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    private let locationManager = CLLocationManager()
    private let activity : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    private let manager = APIManager.sharedInstanse
    
    // VARIABLES
    var allKeysWithinRange : [String] = [String]()
    var userData : [UserDataModel?] = [UserDataModel?]()
    var refreshControll : UIRefreshControl?
    var handleListener : AuthStateDidChangeListenerHandle?
    var uid = Auth.auth().currentUser?.uid
    var userlocation : CLLocation?
    var isqueriedDetalis : Bool = false
    private var userGender : String?
    private var userInterest : String?
    private var localUserInterestRef : DatabaseReference?
    private var isConnectedToNetwork : Bool = false
   
    @IBOutlet var internetConnetionBanner: UIView!
    
    // ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if reachability.connection == .wifi || reachability.connection == .cellular{
            self.isConnectedToNetwork = true
        }
        self.addPulltoRefresh()
        UserDefaults.standard.set(true, forKey: Preferences.logIn.rawValue)
        self.locationManager.startUpdatingLocation()
        self.configureActivity()
        userGender   =  UserDefaults.standard.string(forKey: Preferences.Gender.rawValue)
        userInterest =  UserDefaults.standard.string(forKey: Preferences.InterestedIn.rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(NertworkStatusChanged(notification:)), name: .reachabilityChanged, object: nil)
  }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        let user = Auth.auth().currentUser
        UserToken.sharedInstanse.getUserToken(foruser: user) { (token, error) in
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

        }
     }

    // Custom Method
    
    
    @objc func NertworkStatusChanged(notification : Notification){
        let reachabilty = notification.object as! Reachability
        switch reachabilty.connection {
        case .wifi, .cellular:
            self.isConnectedToNetwork = true
            if self.internetConnetionBanner.transform != .identity
            {
                UIView.animate(withDuration: 0.3, animations: {
                    self.internetConnetionBanner.transform = .identity
                })
            }
        default:
            if self.internetConnetionBanner.transform == .identity
            {
                UIView.animate(withDuration: 0.5, animations: {
                    self.internetConnetionBanner.transform = CGAffineTransform(translationX: 0, y: -bannerHeight)
                })
            }
            self.isConnectedToNetwork = false
            return
        }
    }
    
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
        if let currentInterest = UserDefaults.standard.string(forKey: Preferences.InterestedIn.rawValue){
            self.localUserInterestRef = REF.child("location").child(currentInterest)
        }
      self.loadUsersData(onfireBaseRef: self.localUserInterestRef)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(image: UIImage(named: DARKImage.tuser.rawValue))
    }
   
    func loadUsersData(onfireBaseRef ref : DatabaseReference?){
        guard let userRef = ref else {
            refreshControll?.endRefreshing()
            return}
        guard isConnectedToNetwork else {
            if self.internetConnetionBanner.transform == .identity
            {
                UIView.animate(withDuration: 0.5, animations: {
                    self.internetConnetionBanner.transform = CGAffineTransform(translationX: 0, y: -bannerHeight)
                })
            }
            self.activity.isAnimating ? self.activity.stopAnimating():nil
            refreshControll?.endRefreshing()
            return
        }
        let radious = UserDefaults.standard.integer(forKey: Preferences.Distance.rawValue)
        self.manager.queryUsers(forCurrentuserUID: self.uid!, onUserRef: userRef, intheRadious: Double(radious), userlocation: self.userlocation!, completion: { [weak self] users in
            self?.userData = users
            DispatchQueue.main.async {
                self?.refreshControll?.endRefreshing()
                self?.mycollecion.reloadData()
                (self?.activity.isAnimating)! ? self?.activity.stopAnimating():nil
                
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
    deinit {
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
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
        let availablewidth = collectionView.bounds.width - padding
        let widthPerItem : CGFloat = availablewidth / itemperRow
        return CGSize(width: widthPerItem, height: widthPerItem)
        
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return sectionInset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInset.left
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension UserViewController : CLLocationManagerDelegate{
    
    func updateLocationandLoadUserData(onGenderType gender : String ){
        let currentGender =  gender == Gender.male.rawValue ? Gender.male.rawValue : Gender.female.rawValue
        var  currentInterest : String
        if  self.userInterest == nil {
            currentInterest =  currentGender == Gender.male.rawValue ? Gender.female.rawValue : Gender.male.rawValue
        }else{
            currentInterest = self.userInterest!
        }
        self.localUserInterestRef  = REF.child("location").child(currentInterest)
        let userLocationRef = REF.child("location").child(currentGender)
        self.manager.updateLocation(forUserId: self.uid!, forRef: userLocationRef, location: self.userlocation!)
        self.isqueriedDetalis = true
        self.loadUsersData(onfireBaseRef: self.localUserInterestRef)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userlocation = locations.first
        // Automatic collectionView refresh is not Avaiable to users
        // User need to refresh Collection by pulling it down whenever location change
        if self.isqueriedDetalis == false {
            guard let gender = self.userGender else {
                REF_USER.child(self.uid!).child(DARKFirebaseNode.userInformation.rawValue).child(DARKFirebaseNode.iam.rawValue).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    if snapshot.exists(){
                        let gender = snapshot.value as! String
                         let currentGender =  gender == Gender.male.rawValue ? Gender.male.rawValue : Gender.female.rawValue
                        UserDefaults.standard.set(currentGender, forKey: Preferences.Gender.rawValue)
                        self?.updateLocationandLoadUserData(onGenderType:currentGender)
                    }
                })
            return
            }
         self.updateLocationandLoadUserData(onGenderType: gender)
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.showAlert(title: "Error!", message: "Unable to find location", buttonText: "OK")
    }
}


