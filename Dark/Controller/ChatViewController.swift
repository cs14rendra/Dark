//
//  ChatViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

//TODO: dont reload . insert a row when new chat
// CHECK ALLOCATION OF MESSAGECONTROLLER 
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
private let cellIdetifireXib = "MyCell"
private let tabName = "Chat"
private let estimatedHeight : CGFloat = 75

class ChatViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet var my: UITableView!

    private var channel : [Chat] = [Chat]()
    var uid : String? = Auth.auth().currentUser?.uid
    var handleListener : AuthStateDidChangeListenerHandle?
    var selectedRow : IndexPath?
    var longPress : UILongPressGestureRecognizer!
    var refreshControll : UIRefreshControl?
    
    private lazy var chatList = REF_USER.child(self.uid!).child(DARKFirebaseNode.userchatList.rawValue)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeChannel()
        self.customiseTable()
        self.addPulltoRefresh()
    }
    override func didReceiveMemoryWarning() {
        //TODO: delete row when recive warning 
    }
    func customiseTable(){
        self.my.tableFooterView = UIView()
        self.my.backgroundColor = UIColor.black
    }
    func addPulltoRefresh(){
        refreshControll = UIRefreshControl()
        refreshControll?.bounds = CGRect(x: refreshControll!.bounds.origin.x, y: refreshControll!.bounds.origin.y+50, width: refreshControll!.bounds.size.width, height: refreshControll!.bounds.size.height)
        refreshControll?.tintColor = UIColor.gray
        refreshControll?.addTarget(self, action: #selector(UserViewController.pulltoRefreshTarget), for: .valueChanged)
        self.my.addSubview(refreshControll!)
    }
    
    @objc func pulltoRefreshTarget(){
        self.my.reloadData()
        self.refreshControll?.endRefreshing()
    }
    
    func observeChannel(){
        self.chatList.observe(.childAdded, with: {  [weak self] snapshot in
            if snapshot.exists(){
   
                let convID = snapshot.key as String
                let value = snapshot.value as! [String : Any]
                let timeStamp = value[MessageKey.timeStamp.rawValue] as! Int
                let recieverIDfromServer = value[MessageKey.recieverID.rawValue] as! String
                let chat = Chat(recieverIDfromServer: recieverIDfromServer, timeStamp: timeStamp, convID: convID)
                //self?.channel = (self?.channel.sorted {$0.timeStamp > $1.timeStamp})!
                let a = self?.channel.contains(where: { chat -> Bool in
                    chat.convID == convID
                })
                if let isNewElement = a, isNewElement == false {
                    DispatchQueue.main.async {
                        self?.my.beginUpdates()
                        self?.channel.insert(chat, at: 0)
                        self?.my.insertRows(at: [IndexPath.init(row:0, section:0)], with: .automatic)
                        self?.my.endUpdates()
                    }
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
                // TODO: remove comment
                //self.chatList.child(self.channel[index.row].convID).removeValue()
                self.my.beginUpdates()
                self.channel.remove(at: index.row)
                self.my.deleteRows(at: [index], with: .top)
                self.my.endUpdates()
            }
        }
        optionMenu.addAction(UIAlertAction(title: "cancle", style: .cancel, handler: nil))
        optionMenu.addAction(deleteAction)
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(image: UIImage(named: "ch"))
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
        REF.removeAllObservers()
    }
}


extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Prevent from Reuse
        let cell = Bundle.main.loadNibNamed("UserTableViewCell", owner: self, options: nil)?.first as! ChatTableViewCell
        cell.recieverID = self.channel[indexPath.row].recieverIDfromServer
        cell.cellconvID = self.channel[indexPath.row].convID
        cell.selectionStyle = .none
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed(sender:)))
        cell.addGestureRecognizer(longPress)
       
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return estimatedHeight
    }
    
}


extension ChatViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       let cell = tableView.cellForRow(at: indexPath) as! ChatTableViewCell
        cell.chatText.font = cell.chatText.font.withSize(17)
        cell.chatText.textColor = UIColor.white
        let isNewMessageRef : DatabaseReference =  REF_CHAT.child("\(self.channel[indexPath.row].convID)").child(DARKFirebaseNode.newMessage.rawValue).child(self.uid!)
        isNewMessageRef.setValue(false)
        
        let chatNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatNav") as! UINavigationController
        let dest = chatNav.viewControllers.first as! MessageViewController
        dest.senderDisplayName = ""
        dest.senderId = self.uid
        dest.convID = self.channel[indexPath.row].convID
        dest.recieverID = self.channel[indexPath.row].recieverIDfromServer
        self.present(chatNav, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return estimatedHeight
    }
}
