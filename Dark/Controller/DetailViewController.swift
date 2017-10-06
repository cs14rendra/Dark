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
    
    var id : String?
    var handle : AuthStateDidChangeListenerHandle?
    var userinJSONForm : [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            guard user != nil else {return}
            self.id = user?.uid
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else {return}
        Auth.auth().removeStateDidChangeListener(handle)
    }

    @IBAction func save(_ sender: Any) {
        guard let name = name.text, let age = age.text , name != "", age != "" else {
            print("Empty Data")
            return
        }
        let iam = self.iam.isOn ? "male" : "Female"
        let interestedIn = self.interestedIn.isOn ? "male" : "Female"
        let user = User(name: name, age: Int(age)!, iam: iam, InterestedIn: interestedIn)
        userinJSONForm = user.userDictonary(user: user)
        if JSONSerialization.isValidJSONObject(userinJSONForm!) {
            print("Valid User")
            print(userinJSONForm!)
            guard  let id = self.id else {return}
            ref.child("users").child(id).setValue(self.userinJSONForm)
        }
        
    }
    @IBAction func logOut(sender : UIButton){
        do{
            try Auth.auth().signOut()
            print("Looged out ")
            self.dismiss(animated: true, completion: nil)
        }catch{
            print(error.localizedDescription)
        }
    }
}
