//
//  PhoneSignupViewController.swift
//  Fich
//
//  Created by admin on 7/17/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import PhoneNumberKit

class PhoneSignupViewController: UIViewController {

    // MARK: *** Local variables
    
    // MARK: *** Data Models
    
    // MARK: *** UI Elements
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    // MARK: *** UI Events
    
    @IBAction func onDone(_ sender: UIButton) {
        
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
