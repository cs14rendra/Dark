//
//  SecondViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/5/17.
//  Copyright © 2017 weza. All rights reserved.

import UIKit
import FirebaseAuth
import Firebase
import SkyFloatingLabelTextField
import LGButton
import SDWebImage

class UserDetailsViewController: UIViewController {
    
    // OUTLET
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var interestedIn: UISwitch!
    @IBOutlet var iam: UISwitch!
    @IBOutlet var name: SkyFloatingLabelTextField!
    @IBOutlet var age: SkyFloatingLabelTextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var settingBUtton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var profileImage: UIImageView!
    
    // VARIABLES
    var imagePicker : UIImagePickerController?
    var activeTextField : UITextField?
    var geofire : GeoFire!
    var uid : String? = Auth.auth().currentUser?.uid
    var handle : AuthStateDidChangeListenerHandle?
    var userinJSONForm : [String : Any]?
    var isFromotherUser : Bool?
    var imageToUploadFileURL : NSURL?
    
    //DATA for chat..USERINFO
    var senderID : String?
    var recieverID : String?
    var userInfo : UserDataModel?
    
    // LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLayout()
        self.hideKeyBoardGuesture()
        self.scrollView.canCancelContentTouches = true
        self.scrollView.delaysContentTouches = false
        self.scrollView.isExclusiveTouch = true
        self.checkifFromOtherUserSegue()
        imagePicker  =   self.setUpImagePicker(delegateProvider: self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowing(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHiding(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            guard user != nil else {return}
            self.uid = user?.uid
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else {return}
        Auth.auth().removeStateDidChangeListener(handle)
    }
  
    // OVERRRIDE METHOD
    @objc func keyboardShowing (notification: Notification){
        if let textField  = activeTextField , let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            var aRect = self.view.frame
            aRect.size.height = aRect.size.height - keyboardSize.height
            if (!aRect.contains(textField.frame.origin)){
                self.scrollView.scrollRectToVisible(textField.frame, animated: true)
            }
        }
    }
   
    @objc func keyboardHiding(notification: Notification){
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
 

    // ACTIONS
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = name.text, let age = age.text , name != "", age != "" else {
            print("Empty Data")
            return
        }
        let iam = self.iam.isOn ? "male" : "Female"
        let interestedIn = self.interestedIn.isOn ? "male" : "Female"
        let user = User(name: name, age: Int(age)!, iam: iam, InterestedIn: interestedIn, profilePicURL : "")
        let encoder = JSONEncoder()
        do{
            let userDetalis = try encoder.encode(user)
            let object = try JSONSerialization.jsonObject(with: userDetalis, options: .mutableContainers)
            ref.child("users").child(self.uid!).child("userInformation").setValue(object)
             self.showAlert(title: "Saved", message: "Details saved successfully", buttonText: "OK")
            self.saveUserImage()
        }catch{
            print(error.localizedDescription)
        }
    }
  
    @IBAction func settings(_ sender: Any) {
    }
    
    @IBAction func edit(_ sender: Any) {
        guard let fromOtherUser = isFromotherUser, fromOtherUser == true else{
            self.editLayout()
            //TODO: add auth==currentuser
            self.name.becomeFirstResponder()
            return
        }
       self.performSegue(withIdentifier: "chatController", sender: self)
    }
    
    @IBAction func upload(_ sender: Any) {
        self.showImagePicker(imagePicker: imagePicker!)
    }
    
    @IBAction func logOut(sender : UIButton){
        do{
            try Auth.auth().signOut()
            self.resetApp()
        }catch{
            print(error.localizedDescription)
        }
    }
    // CUSTOM METHOD
    func saveUserImage() {
        self.startLayout()
        let profilePicRef = storageRef.child(self.uid!).child("profilePic.png")
        var imageDownloadURL = ""
        userRef.child(self.uid!).child("userInformation").child("profilePicURL").observeSingleEvent(of: .value) { (snapshot) in
            let profilePicURL = snapshot.value as? String
            if profilePicURL == "" {
                let imageData = UIImagePNGRepresentation(UIImage(named: "boy")!)
                profilePicRef.putData(imageData!, metadata: nil, completion: { (metaData, error) in
                    guard error == nil else {return}
                    imageDownloadURL = (metaData?.downloadURL()?.absoluteString)!
                    print(imageDownloadURL)
                    userRef.child(self.uid!).child("userInformation").child("profilePicURL").setValue(imageDownloadURL)
                   
                })
            }
        }
  
    }
   
    func setprofileImage(){
        let data = NSData(contentsOf: self.imageToUploadFileURL! as URL)
        self.profileImage.image = UIImage(data: data! as Data)
    }
    
    func  checkifFromOtherUserSegue(){
        guard let fromOtherUser = isFromotherUser, fromOtherUser == true else{return}
        self.settingBUtton.isHidden = true
        self.saveButton.isHidden = true
        self.editButton.setImage(UIImage(named:"chat"), for: .normal)
    }
    
    func hideKeyBoardGuesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(done))
        self.contentView.isUserInteractionEnabled = true
        self.contentView.addGestureRecognizer(tap)
    }
    @objc func done(){
        self.view.endEditing(true)
    }
    
    // SEGUE METHOD
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatController"{
            let dst = segue.destination.childViewControllers.first as! MessageViewController
            dst.senderDisplayName = "NO NAME"
            dst.senderId = self.senderID
            dst.recieverID = self.recieverID
        }
    }
        
}

// EXTENTIONS
extension UserDetailsViewController {
    func startLayout(){
    setUserInfo()
    self.uploadButton.isHidden = true
    self.name.isEnabled = false
    self.age.isEnabled = false
    self.iam.isEnabled = false
    self.interestedIn.isEnabled = false
    self.saveButton.isHidden = true
    }
    func editLayout(){
        self.uploadButton.isHidden = false
        self.name.isEnabled = true
        self.age.isEnabled = true
        self.iam.isEnabled = true
        self.interestedIn.isEnabled = true
        self.saveButton.isHidden = false
    }
    
    func setUserInfo(){
        print(self.userInfo)
        loadImage(link: (self.userInfo?.profilePicURL)!)
        self.imageToUploadFileURL = NSURL(string: (self.userInfo?.profilePicURL)!)

    }
    
    func loadImage(link : String){
            let url = URL(string: link)
            self.profileImage .sd_setImage(with: url , placeholderImage: UIImage(named:"blank"), options:.continueInBackground, progress: nil, completed: nil)
    }

}

extension UserDetailsViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField{
            nextTextField.becomeFirstResponder()
        }else{
          textField.resignFirstResponder()
        }
        return true
    }
}


extension UserDetailsViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate{

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerImageURL] {
            print(image)
            self.imageToUploadFileURL = image as? NSURL
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }
}

