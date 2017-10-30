//
//  SettingsViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/29/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func logOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.resetApp()
        }catch{
            print(error.localizedDescription)
        }
    }

}
