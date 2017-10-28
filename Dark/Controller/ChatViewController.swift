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

struct Chat{
    var recieverIDfromServer : String
    var timeStamp : Int
}

class ChatViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet var my: UITableView!
    
    let name = "Surendra"
    var channel : [(key:String,value:Chat)] = [(key:String,value:Chat)]()
    
    var uid : String? = Auth.auth().currentUser?.uid
    var handle : FirebaseHandle?
    var handleListener : AuthStateDidChangeListenerHandle?
    lazy var channelRef = ref.child("Channels")

    private lazy var chatList = ref.child("users").child(self.uid!).child("userchatList")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeChannel()
    }
    

    func observeChannel(){
        
        handle = self.chatList.observe(.childAdded, with: { snapshot in
            if snapshot.exists(){
               print(self.chatList)
                
                let id = snapshot.key as String
                print(snapshot.value)
                let value = snapshot.value as! [String : Any]
                let timeStamp = value["timeStamp"] as! Int
                let recieverIDfromServer = value["recieverID"] as! String
                let temp = Chat(recieverIDfromServer: recieverIDfromServer, timeStamp: timeStamp)
                let t = (id,temp)
                self.channel.append(t)
                self.channel = self.channel.sorted {$0.1.timeStamp > $1.1.timeStamp}
                DispatchQueue.main.async {
                    self.my.reloadData()
                }
            }else{
                print("not exist ")
            }
            
        })
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "chat")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat" {
            if let index = self.my.indexPathForSelectedRow {
                let dest = segue.destination.childViewControllers.first as! MessageViewController
                dest.senderDisplayName = "surendra"
                dest.senderId = self.uid
                dest.convID = String(Array(channel)[index.row].key)
                dest.recieverID = String(Array(channel)[index.row].value.recieverIDfromServer)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatTableViewCell

        cell.recieverID = String(Array(channel)[indexPath.row].value.recieverIDfromServer)
        cell.chatText.text = String(Array(channel)[indexPath.row].value.timeStamp)
        return cell
    }
    
    
}
