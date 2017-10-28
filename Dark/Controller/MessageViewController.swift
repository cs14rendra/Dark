//
//  MessageViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import  JSQMessagesViewController
import Firebase
import FirebaseDatabase

struct ChatMetaData : Codable{
    var timeStamp  : Int
    var recieverID : String
}

class MessageViewController: JSQMessagesViewController {
    
    var recieverID : String?
    var convID : String?
    let uid = Auth.auth().currentUser?.uid
   
    private lazy var messageRef: DatabaseReference = ref.child("Chat") .child("\(String(describing: convID!))").child("messages")
    private lazy var isUserTypingRef : DatabaseReference = ref.child("Chat").child(self.convID!).child("isUserTyping").child(self.senderId)
    private lazy var userTypingQuery : DatabaseQuery = ref.child("Chat").child(self.convID!).child("isUserTyping").queryOrderedByValue().queryEqual(toValue: true)
    private var localtyping = false
    private var isTyping : Bool {
    get{
    return localtyping
    }
    set{
    localtyping = newValue
        isUserTypingRef.setValue(newValue)
    }
    }
    
    var isRunOneTime : Bool = false
    private var handle: DatabaseHandle?
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var imagePicker : UIImagePickerController!
    private var photoMessageMap = [String : JSQPhotoMediaItem]()
    
  var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         title = self.senderDisplayName
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let lb = UIButton(frame: CGRect(x: 10, y: 30, width: 100, height: 45))
        lb.setTitle("back", for: .normal)
        lb.setTitleColor(UIColor.blue, for: .normal)
        lb.addTarget(self, action: #selector(targetbutton), for: .touchUpInside)
        self.view.insertSubview(lb, at: 1)
        
        // Method
        self.InitialiseConversationID()
        finishReceivingMessage()
        self.observeMessages()
        
        //picker
        imagePicker = self.setUpImagePicker(delegateProvider: self)
    }
    

    
    @objc func targetbutton(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func dis(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    func InitialiseConversationID(){
        guard convID == nil else {return}
        let senderID5 = String(senderId.characters.prefix(5))
        let recieverID5 = String(recieverID!.characters.prefix(5))
        if (senderID5 > recieverID5){
            self.convID = senderID5 + recieverID5
        }else{
            self.convID = recieverID5 + senderID5
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.obeserveTyping()
       
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        }else{
            return incomingBubbleImageView
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withID id : String, key : String , mediaItem : JSQPhotoMediaItem){
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem){
            messages.append(message)
            if (mediaItem.image == nil){
                photoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        if !isRunOneTime{
            let senderChatref = ref.child("users").child(senderId).child("userchatList").child(self.convID!)
            let recieverChatref = ref.child("users").child(recieverID!).child("userchatList").child(self.convID!)
            let serderChatMetaData = ChatMetaData(timeStamp: Int(Date().timeIntervalSince1970), recieverID: self.recieverID!)
            let recieverChatMetaData = ChatMetaData(timeStamp: Int(Date().timeIntervalSince1970), recieverID: self.senderId!)
            
            let encoder = JSONEncoder()
            do{
                let temp1 = try encoder.encode(serderChatMetaData)
                let object1 = try JSONSerialization.jsonObject(with: temp1, options: .mutableContainers)
                senderChatref.setValue(object1)
                // for Reciever
                
                let temp2 = try encoder.encode(recieverChatMetaData)
                let object2 = try JSONSerialization.jsonObject(with: temp2, options: .mutableContainers)
                 recieverChatref.setValue(object2)
                
                self.isRunOneTime = true
                
            }catch{
                print(error.localizedDescription)
            }

        }
        self.isTyping = false
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("Select From Gallery")
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func observeMessages() {
        let messageQuery = messageRef.queryLimited(toLast:25)
        handle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
         
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
        
                self.addMessage(withId: id, name: name, text: text)
                
                
                self.finishReceivingMessage()
              // Decode if message 
            }else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withID: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            }
        })
        
        messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
    }
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
        
    }
    func obeserveTyping(){
     self.isUserTypingRef.onDisconnectRemoveValue()
        userTypingQuery.observe(.value) { snapshot in
            if snapshot.childrenCount == 1 && self.isTyping == true {return}
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
}

extension MessageViewController{
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        let messageItem =  [
            "photoURL": "",
            "senderId": senderId!
            ]
        itemRef.setValue(messageItem)
        finishSendingMessage()
        return itemRef.key // conv ID
    }
    
    func setImageURL(url : String ,forPhotoMessageWithKey key : String){
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = Storage.storage().reference(forURL: photoURL)
    
        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
           
                mediaItem.image = UIImage.init(data: data!)
                
                self.collectionView.reloadData()
                
            
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            
        }
    }
}

extension MessageViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Image URL
        if let imageURL = info[UIImagePickerControllerImageURL] {
          
            if let key = self.sendPhotoMessage(){
                storageRef.child(senderId).putFile(from: imageURL as! URL, metadata: nil, completion: { metadata, error in
                    if error != nil {
                        return
                    }
                    self.setImageURL(url: (metadata?.downloadURL()?.absoluteString)!, forPhotoMessageWithKey: key)
                })
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}

