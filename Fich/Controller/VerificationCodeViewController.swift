//
//  VerificationCodeViewController.swift
//  Fich
//
//  Created by admin on 7/17/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import FirebaseAuth

class VerificationCodeViewController: UIViewController {

    // MARK: *** Local variables
    var counter = 59
    var timer = Timer()
    var PHONENUMBER_KEY = "phonenumber"
    var VERIFICATIONID_KEY = "authVerificationID"
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var pleaseWaitLabel: UILabel!
    @IBOutlet weak var didntReceiveCode: UILabel!
    @IBOutlet weak var resendSMS: UIButton!
    
    // MARK: *** UI Events
    @IBAction func onLogin(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: PHONENUMBER_KEY)!, verificationCode: codeTextField.text!)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil{
                print("error: \(String(describing: error?.localizedDescription))")
            }else{
                UserDefaults.standard.set("User logged in by phonenumber", forKey: "user")
                print("Phone number: \(String(describing: user?.phoneNumber))")
                let userInfo = user?.providerData[0]
                print("Provider ID: \(String(describing: userInfo?.providerID))")
                self.performSegue(withIdentifier: "segueToLoggedIn", sender: self)
            }
        }
    }
    
    @IBAction func onResend(_ sender: Any) {
        counter = 59
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        didntReceiveCode.isHidden = true
        resendSMS.isHidden = true
        pleaseWaitLabel.isHidden = false
        PhoneAuthProvider.provider().verifyPhoneNumber(UserDefaults.standard.value(forKey: PHONENUMBER_KEY) as! String) { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("successfully sent")
                UserDefaults.standard.set(verificationID, forKey: self.VERIFICATIONID_KEY)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        if counter != 0{
            didntReceiveCode.isHidden = true
            resendSMS.isHidden = true
        }
    }
    
    func updateTime(){
        counter -= 1
        if counter == 0{
            timer.invalidate()
            didntReceiveCode.isHidden = false
            resendSMS.isHidden = false
            pleaseWaitLabel.isHidden = true
        }
        pleaseWaitLabel.text = "Please wait... \(counter)s"
    }
}
