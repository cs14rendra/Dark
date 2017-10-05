//
//  ViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/5/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import FirebaseAuth
class ViewController: UIViewController {

    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    var  handle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let user = user else {return}
            self.performSegue(withIdentifier: "show", sender: self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else {return }
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    @IBAction func okButton(_ sender: Any) {
        guard let email = email.text, let password = password.text, email != "", password != "" else  {
            print("empty field")
            return }
         //Sign UP
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard error != nil else {
                print(error?.localizedDescription)
                return
            }
            print("UID :\(user?.uid)")
        }
        
//        //Sign In
//        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
//            guard error == nil else {
//                print(error?.localizedDescription)
//                return
//                }
//            self.performSegue(withIdentifier: "show", sender: self)
//         }
  }
    
}

