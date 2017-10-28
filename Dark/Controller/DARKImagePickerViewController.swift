//
//  DARKImagePickerViewController.swift
//  Dark
//
//  Created by surendra kumar on 10/26/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit


extension UIViewController {

   
    func setUpImagePicker(delegateProvider : UIViewController) -> UIImagePickerController{
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegateProvider as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
        imagePicker.popoverPresentationController?.sourceView = self.view
        return imagePicker
    }
    func showImagePicker(imagePicker : UIImagePickerController){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
}


