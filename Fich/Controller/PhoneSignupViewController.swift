//
//  PhoneSignupViewController.swift
//  Fich
//
//  Created by admin on 7/17/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import PhoneNumberKit
import FirebaseAuth

class PhoneSignupViewController: UIViewController {

    // MARK: *** Local variables
    var VERIFICATIONID_KEY = "authVerificationID"
    var PHONENUMBER_KEY = "phonenumber"
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    // MARK: *** UI Events
    @IBAction func onBackLogin(_ sender: Any) {
        print("On back")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: UIButton) {
        let alert = UIAlertController(title: "Phone number", message: "Is this your phone number? \n \(phoneTextField.text!)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneTextField.text!) { (verificationID, error) in
                if error != nil{
                    print("error: \(String(describing: error?.localizedDescription))")
                }else{
                    UserDefaults.standard.set(verificationID, forKey: self.VERIFICATIONID_KEY)
                    UserDefaults.standard.set(self.phoneTextField.text!, forKey: self.PHONENUMBER_KEY)
                    self.performSegue(withIdentifier: "segueToGetCode", sender: self)
                }
            }
        })
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    func setupLayout(){
        phoneTextField.useUnderline()
        addDoneButton(to: phoneTextField)
        doneBtn.layer.cornerRadius = doneBtn.frame.height/2
        doneBtn.clipsToBounds = true
        doneBtn.layer.shadowOffset = CGSize(width: -1, height: 1)
        doneBtn.layer.shadowOpacity = 0.2
    }
}
