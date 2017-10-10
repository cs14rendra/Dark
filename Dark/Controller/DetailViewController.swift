//
//  SecondViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/5/17.
//  Copyright © 2017 weza. All rights reserved.

import UIKit
import FirebaseAuth
import Firebase

class SecondViewController: UIViewController {
    
    @IBOutlet var interestedIn: UISwitch!
    @IBOutlet var iam: UISwitch!
    @IBOutlet var age: UITextField!
    @IBOutlet var name: UITextField!
    
    var geofire : GeoFire!
    var uid : String?
    var handle : AuthStateDidChangeListenerHandle?
    var userinJSONForm : [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            guard user != nil else {return}
            self.uid = user?.uid
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else {return}
        Auth.auth().removeStateDidChangeListener(handle)
    }

    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: Any) {
        guard let name = name.text, let age = age.text , name != "", age != "" else {
            print("Empty Data")
            return
        }
        let iam = self.iam.isOn ? "male" : "Female"
        let interestedIn = self.interestedIn.isOn ? "male" : "Female"
        let user = User(name: name, age: Int(age)!, iam: iam, InterestedIn: interestedIn, profilePicURL : "")
        userinJSONForm = user.userDictonary(user: user)
        if JSONSerialization.isValidJSONObject(userinJSONForm!) {
            print("Valid User")
            print(userinJSONForm!)
            guard  let uid = self.uid else {return}
            userRef.child(uid).child("userInformation").setValue(self.userinJSONForm)
           // self.updateLocation(forId: uid)
            self.saveUserImage()
            
        }
        
    }
    
    func saveUserImage() {
        let profilePicRef = storageRef.child(self.uid!).child("profilePic.png")
        var imageDownloadURL = ""
        userRef.child(self.uid!).child("profilePicURL").observeSingleEvent(of: .value) { (snapshot) in
            let profilePicURL = snapshot.value as? String
            if profilePicURL == "" {
                let imageData = UIImagePNGRepresentation(UIImage(named: "boy")!)
                profilePicRef.putData(imageData!, metadata: nil, completion: { (metaData, error) in
                    guard error == nil else {return}
                    imageDownloadURL = (metaData?.downloadURL()?.absoluteString)!
                    print(imageDownloadURL)
                    userRef.child(self.uid!).child("userInformation").child("profilePicURL").setValue(imageDownloadURL)
                   
                })
            }
        }
  
    }
    @IBAction func logOut(sender : UIButton){
        do{
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "logIn")
            print("Looged out ")
            //self.dismiss(animated: true, completion: nil)
            let singUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signUp")
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window?.rootViewController = singUpViewController
        }catch{
            print(error.localizedDescription)
        }
    }

}
