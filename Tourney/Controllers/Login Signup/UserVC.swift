//
//  UserVC.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 5/28/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Photos

class UserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var userImagePicker: UIImageView!
    @IBOutlet weak var completeSignInBtn: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var signUpEmailField: UITextField!
    @IBOutlet weak var signUpPasswordField: UITextField!
    
    var userUid: String!
    var emailField: String!
    var passwordField: String!
    var imagePicker: UIImagePickerController!
    var username: String!
    var imageSelected = false
    var dynamicLinkTourneyId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.usernameField.delegate = self
        print(dynamicLinkTourneyId)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - Actions
    
    @IBAction func completeAccount(_ sender: LoadingUIButton){
        
        // alert user if profile picture has not been set
        if imageSelected == false {
            alert(title: "Profile Picture", message: "Set up a profile picture before creating an account!")
            return
        }
        // alert username has not been set
        if let username = usernameField.text {
            if username.count == 0 {
                alert(title: "Username", message: "Make sure you choose a username before continuing!")
                return
            }
        }
        
        // show loading on button
        sender.showLoading()
        
        Auth.auth().createUser(withEmail: signUpEmailField.text!, password: signUpPasswordField.text!, completion: {
            (user, error) in
            if let error = error {
                // stop loading on button
                sender.hideLoading()
                print("@willcohen There is an error in UserVC: \(String(describing: error.localizedDescription))")
                self.alert(title: "Oh Oh", message: error.localizedDescription)
            } else{
                if let user = user{
                    self.userUid = user.user.uid
                    User.sharedInstance.uid = user.user.uid
                    self.uploadImg(completionHandler: { (success) in
                        // stop loading on button
                        sender.hideLoading()
                        if (success) {
                            self.setUpUserAndContinue()
                        } else {
                            print("@willcohen somethign went wrong")
                        }
                    })
                }
            }
        })
    }
    
    @IBAction func selectedImagePicker(_ sender: Any){
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func keychain(){
        KeychainWrapper.standard.set(userUid, forKey: "uid")
    }
    
    func setUpUserAndContinue(){
        let userData = [
            "username": username,
            "email": emailField
        ]
        keychain()
        let setLocation = Database.database().reference().child("users").child(userUid)
        setLocation.updateChildValues(userData)
        DatabaseService.loadSingletonData { (success) in
            self.performSegue(withIdentifier: "toFeedSegue", sender: nil);
        }
        
    }
    
    func checkPermissions() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                   
                } else {
                  print("do something ehre tohandle")
                }
            })
        }
    }
    
    func uploadImg(completionHandler: @escaping (_ success: Bool) -> Void) {
        
        if (usernameField.text == nil) {
            completeSignInBtn.isEnabled = false
        } else {
            username = usernameField.text
            emailField = signUpEmailField.text
            completeSignInBtn.isEnabled = true
        }

        guard let img = userImagePicker.image, imageSelected == true else {
            print("Image must be selected")
            completionHandler(false)
            return
        }
        
        let storageReference = Storage.storage().reference().child("users").child(userUid)
        let imageData = img.jpegData(compressionQuality: 0.1);
        
        storageReference.putData(imageData!, metadata: nil, completion: { (metaData, error) in
            if (error != nil) {
                print("@willcohen see this message: \(error?.localizedDescription)")
                completionHandler(false)
            } else {
                print("@willcohen this must have worked ")
                storageReference.downloadURL { url, error in
                    Database.database().reference().child("users").child(self.userUid).child("profileImageUrl").setValue(url!.absoluteString)
                    completionHandler(true)
                }
            }
        })
        
    }
    
    
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return (true)
    }
    
    // MARK: - ImagePicker Delegate

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        checkPermissions()
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            userImagePicker.image = image
            imageSelected = true
        } else {
            print("@willcohen Image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFeedSegue" {
            if let dynamicLinkTourneyId = dynamicLinkTourneyId {
                let feedVC = segue.destination as! TableViewController
                feedVC.dynamicLinkTourneyId = dynamicLinkTourneyId
            }                        
        }
    }
}
