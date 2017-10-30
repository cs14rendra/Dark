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

private struct Chat{
    var recieverIDfromServer : String
    var timeStamp : Int
    var convID : String
}
private enum MessageKey : String{
    case timeStamp
    case recieverID
}
private enum ControllerSegue : String{
    case chat
}
private let reusableCellIdentifire = "Cell"
private let tabName = "Chat"

class ChatViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet var my: UITableView!

    private var channel : [Chat] = [Chat]()
    var uid : String? = Auth.auth().currentUser?.uid
    var handle : FirebaseHandle?
    var handleListener : AuthStateDidChangeListenerHandle?
    lazy var channelRef = REF_CHANNEL
    private lazy var chatList = REF_USER.child(self.uid!).child(DARKFirebaseNode.userchatList.rawValue)
    var selectedRow : IndexPath?
    var longPress : UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeChannel()
        self.customiseTable()
    }
    
    func customiseTable(){
        self.my.tableFooterView = UIView()
        self.my.backgroundColor = UIColor.black
    }
    
    func observeChannel(){
        handle = self.chatList.observe(.childAdded, with: { snapshot in
            if snapshot.exists(){
                print(snapshot.key)
                let convID = snapshot.key as String
                let value = snapshot.value as! [String : Any]
                let timeStamp = value[MessageKey.timeStamp.rawValue] as! Int
                let recieverIDfromServer = value[MessageKey.recieverID.rawValue] as! String
                let chat = Chat(recieverIDfromServer: recieverIDfromServer, timeStamp: timeStamp, convID: convID)
                self.channel.append(chat)
                self.channel = self.channel.sorted {$0.timeStamp > $1.timeStamp}
                DispatchQueue.main.async {
                    self.my.reloadData()
                }
            }else{
                print("not exist ")
            }
        })
    }
    
    @objc func cellLongPressed(sender : UILongPressGestureRecognizer){
        guard sender.state == .began else {return}
        self.selectedRow = self.my.indexPathForRow(at: sender.location(in: self.my))
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            if let index = self.selectedRow{
                print(index)
                self.chatList.child(self.channel[index.row].convID).removeValue()
                self.channel.remove(at: index.row)
                self.my.deleteRows(at: [index], with: .top)
            }
        }
        optionMenu.addAction(UIAlertAction(title: "cancle", style: .cancel, handler: nil))
        optionMenu.addAction(deleteAction)
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ControllerSegue.chat.rawValue {
            if let index = self.my.indexPathForSelectedRow {
                let dest = segue.destination.childViewControllers.first as! MessageViewController
                //TODO : add disaplay name 
                dest.senderDisplayName = ""
                dest.senderId = self.uid
                dest.convID = self.channel[index.row].convID
                dest.recieverID = self.channel[index.row].recieverIDfromServer
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifire, for: indexPath) as! ChatTableViewCell
        cell.recieverID = self.channel[indexPath.row].recieverIDfromServer
        cell.selectionStyle = .gray
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed(sender:)))
        cell.addGestureRecognizer(longPress)
        return cell
    }
    
}
extension ChatViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
   
}
