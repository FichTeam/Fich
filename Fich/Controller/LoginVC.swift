//
//  LoginVC.swift
//  Fich
//
//  Created by admin on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginVC: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: *** Local variables
    let permissionsToRead = ["public_profile", "email"]
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    
    
    // MARK: *** UI Events
    @IBAction func onSignupNumber(_ sender: UIButton) {
        performSegue(withIdentifier: "segueVerifyNumber", sender: self)
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        self.btnFacebook.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        initButton()
        
        btnFacebook.readPermissions = permissionsToRead
        let token = UserDefaults.standard.string(forKey: "token")
        if token != nil{ //user already logged in
            print("User logged in viewDidLoad")
        }else{
            print("User logged out")
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        let token = UserDefaults.standard.string(forKey: "token")
        if token != nil{
            moveToHome()
        }else{
            print("User logged out")
        }
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            // Process error
            print("Error")
        }
        else if result.isCancelled {
            // Handle cancellations
            print("Cancelled")
        }
        else {
            // Navigate to other view
            print("Success")
            if result.grantedPermissions.contains("email") {
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        print("erroe: \(error.localizedDescription)")
                        return
                    }
                    print("login firebase success")
                    FirebaseClient.sharedInstance().update()
                }
                moveToHome()
            }
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Out")
        UserDefaults.standard.set(nil, forKey: "token")
    }
    func moveToHome() {
//        let lobbyVC = LobbyViewController(nibName: "LobbyViewController", bundle: nil)
//        present(lobbyVC, animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "JoinLobby", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"lobbyVC")
        present(viewController, animated: true)
    }
    
    func initButton(){
        btnPhone.layer.cornerRadius = btnPhone.frame.height/2
        btnPhone.clipsToBounds = true
        btnPhone.layer.shadowOffset = CGSize(width: -1, height: 1)
        btnPhone.layer.shadowOpacity = 0.2
        
        btnFacebook.layer.cornerRadius = btnPhone.frame.height/2
        btnFacebook.clipsToBounds = true
        btnFacebook.layer.shadowOffset = CGSize(width: -1, height: 1)
        btnFacebook.layer.shadowOpacity = 0.2
    }
}
