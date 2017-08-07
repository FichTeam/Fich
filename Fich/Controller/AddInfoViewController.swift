//
//  AddInfoViewController.swift
//  Fich
//
//  Created by admin on 8/5/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase

class AddInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBAction func onGo(_ sender: UIButton) {
        if name.text!.characters.count > 3 && selectedImages != nil{
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name.text!
            changeRequest?.photoURL = URL(string: imageURL!)!
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }else{
                    UserDefaults.standard.set("User logged in by phonenumber", forKey: "user")
                    let storyboard = UIStoryboard(name: "JoinLobby", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"lobbyVC")
                    self.present(viewController, animated: true)
                }
            })
            FirebaseClient.sharedInstance.update()
        }else{
            alert(title: "Oops", message: "Your name must have at least 4 characters and you must have avatar!")
        }
    }
    @IBAction func onPickImage(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButton(to: name)
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    // MARK: *** UIImagePicker
    var selectedImages : UIImage? = nil
    var imageURL: String? = nil
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatar.image = pickedImage
            selectedImages = pickedImage
        }
        
        if let  uid = Auth.auth().currentUser?.uid{
            let storageRef = Storage.storage().reference().child("avatar").child("\(uid).png")
            if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                if let uploadData = UIImageJPEGRepresentation(originalImage, 0.7) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let imageUrl = metadata?.downloadURL()?.absoluteString {
                            print("printam")
                            print(imageUrl)
                            self.imageURL = imageUrl
                        }
                        
                    })
                    
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}
