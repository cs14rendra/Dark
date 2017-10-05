//
//  SecondViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/5/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
