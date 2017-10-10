//
//  DetailViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/5/17.
//  Copyright © 2017 weza. All rights reserved.


import UIKit
import FirebaseAuth

class DetailViewController: UIViewController {
    
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    var  handle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
    }
    @IBAction func back(sender : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okButton(_ sender: Any) {
        guard let email = email.text, let password = password.text, email != "", password != "" else  {
            print("empty fieldjijoi")
            return }
        // Sign In
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Error in Sign In")
                return
            }
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
    }
}
