//
//  ChatViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FirebaseAuth
import Firebase


class ChatViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet var my: UITableView!
    
    let name = "Surendra"
    var channel : [String : Int] = [String : Int]()
    var uid : String = "uRgmCWCOBIS8wCXHvC9Zs8k0Qv93"
    var handle : FirebaseHandle?
    var handleListener : AuthStateDidChangeListenerHandle?
    lazy var channelRef = ref.child("Channels")

    private lazy var chatList = ref.child("users").child("uRgmCWCOBIS8wCXHvC9Zs8k0Qv93").child("userchatList")
    
    override func viewDidLoad() {
        super.viewDidLoad()
     self.observeChannel()
    }
    

    func observeChannel(){
        handle = self.chatList.observe(.childAdded, with: { snapshot in
            let id = snapshot.key as String
            let timestamp = snapshot.value as! Int
            self.channel.updateValue(timestamp, forKey: id)
            self.my.reloadData()
        })
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "chat")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat" {
            if let index = self.my.indexPathForSelectedRow {
                let dest = segue.destination as! MessageViewController
                dest.senderDisplayName = "surendra"
                dest.senderId = self.uid
                dest.convID = String(Array(channel)[index.row].key)
            }
        }
    }
    deinit {
        guard let handle = handle else {return}
        self.channelRef.removeObserver(withHandle: handle)
    }
}

extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = String(Array(channel)[indexPath.row].key)
        return cell
    }
    
    
}
