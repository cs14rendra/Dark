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
import DatePickerDialog
import SwiftDate

private enum ControllerSegue : String{
    case chatController
}
private let profilePicNode = "profilePicURL"
private let defaultDisplayName = ""
private let storageChildNodeName = "profilePic.png"
private let dateTextFieldTag = 99

class UserDetailsViewController: UIViewController {
    
    // OUTLET
    @IBOutlet var genderView: UIView!
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
    var imageToUploadFileURL : NSURL?
    var imageURL : String?
    var userBirthday : NSNumber?
    
    //DATA for chat..USERINFO
    var userInfo : UserDataModel?
    
    // LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        title = self.userInfo?.name
        self.startLayout()
        self.hideKeyBoardGuesture()
        self.scrollView.canCancelContentTouches = true
        self.scrollView.delaysContentTouches = false
        self.scrollView.isExclusiveTouch = true
        self.checkifFromOtherUserSegue()
        imagePicker =  self.setUpImagePicker(delegateProvider: self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowing(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHiding(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height / 2
        self.profileImage.layer.masksToBounds = true
        self.profileImage.layer.borderColor = DARKPINK.cgColor
        self.profileImage.layer.borderWidth = 1.0
        self.age.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ageTextfieldDidTapped)))
    }
    
    @objc func ageTextfieldDidTapped(){
        print("tapped")
        DatePickerDialog().show("BirthDay", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: (Date() - 13.years), minimumDate: (Date() - 99.years), maximumDate: (Date() - 13.years), datePickerMode: .date) { date in
            if let newdate = date {
                self.userBirthday = newdate.timeIntervalSince1970 as NSNumber
                self.age.text = String(newdate.yearBetweenDate(startDate: newdate, endDate: Date()))
                
            }
        }
        
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
        let name = self.name.text
        let iam = self.iam.isOn ? Gender.male.rawValue : Gender.female.rawValue
        let interestedIn = self.interestedIn.isOn ? Gender.male.rawValue : Gender.female.rawValue
        let user = User(name: name ?? "", age: self.userBirthday as! Int, iam: iam, InterestedIn: interestedIn, profilePicURL : imageURL ?? "")
        do{
            let coder = DARKCoder.sharedInstanse
            let object = try coder.encode(user: user)
            REF_USER.child(self.uid!).child(DARKFirebaseNode.userInformation.rawValue).setValue(object)
            self.saveUserImage()
            self.showAlert(title: "Saved", message: "Details saved successfully", buttonText: "OK")
        }catch{
            print(error.localizedDescription)
        }
    }
  

    @IBAction func edit(_ sender: Any) {
        guard !isCurrentUser() else{
            self.editLayout()
            self.name.becomeFirstResponder()
            return
        }
       self.performSegue(withIdentifier: ControllerSegue.chatController.rawValue, sender: self)
    }
    
    @IBAction func upload(_ sender: Any) {
        self.showImagePicker(imagePicker: imagePicker!)
    }
    
   
    // CUSTOM METHOD
    func saveUserImage() {
        self.startLayout()
        let profilePicRef = REF_STORAGE.child(self.uid!).child(storageChildNodeName)
        var imageDownloadURL = ""
        REF_USER.child(self.uid!).child(DARKFirebaseNode.userInformation.rawValue).child(profilePicNode).observeSingleEvent(of: .value) { (snapshot) in
            // TODO: remove observer
            if let url  = self.imageToUploadFileURL {
                do{
                    let data = try Data(contentsOf: url as URL)
                    profilePicRef.putData(data, metadata: nil, completion: { (metaData, error) in
                        guard error == nil else {return}
                        imageDownloadURL = (metaData?.downloadURL()?.absoluteString)!
                        REF_USER.child(self.uid!).child(DARKFirebaseNode.userInformation.rawValue).child(profilePicNode).setValue(imageDownloadURL)
                        
                    })
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
  
    }
   
    func setprofileImage(){
        let data = NSData(contentsOf: self.imageToUploadFileURL! as URL)
        self.profileImage.image = UIImage(data: data! as Data)
    }
    
    func  checkifFromOtherUserSegue(){
        guard !isCurrentUser() else{return}
        self.settingBUtton.isHidden = true
        self.saveButton.isHidden = true
        self.editButton.setImage(UIImage(named:DARKImage.chat.rawValue), for: .normal)
    }
    
    func isCurrentUser () -> Bool{
        return self.userInfo?.uid == self.uid
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
        if segue.identifier == ControllerSegue.chatController.rawValue{
            let dst = segue.destination.childViewControllers.first as! MessageViewController
            dst.senderDisplayName = self.userInfo?.name ?? defaultDisplayName
            dst.senderId = self.uid
            dst.recieverID = self.userInfo?.uid
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
        if isCurrentUser(){
            self.genderView.isHidden = true
        }
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
        if let name = self.userInfo?.name{
            self.name.text = name
        }
        
        if let age = self.userInfo?.age {
            let date = Date(timeIntervalSince1970: TimeInterval(age))
            let year = date.yearBetweenDate(startDate: date, endDate: Date())
            self.age.text = String(year)
        }
        
        if let iam = self.userInfo?.iam , iam == Gender.male.rawValue{
            self.iam.setOn(true, animated: false)
        }else{
            self.iam.setOn(false, animated: false)
        }
        
        if let interested = self.userInfo?.InterestedIn , interested == Gender.male.rawValue{
            self.interestedIn.setOn(true, animated: false)
        }else{
            self.interestedIn.setOn(false, animated: false)
        }
        self.loadImage(link: self.userInfo?.profilePicURL)
        self.imageURL = self.userInfo?.profilePicURL
        self.userBirthday = self.userInfo?.age as NSNumber?
    }
    
    func loadImage(link : String?){
        let url : URL?
        if let mylink = link {
            url = URL(string: mylink)
        }else{
            url = nil
        }
        self.profileImage .sd_setImage(with: url , placeholderImage: UIImage(named:DARKImage.blank.rawValue), options:.continueInBackground, progress: nil, completed: nil)
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
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == dateTextFieldTag {
            return false
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

