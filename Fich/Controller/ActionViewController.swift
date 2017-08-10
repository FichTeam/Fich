//
//  ChatViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/31/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase

class ActionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
    
    var bottomHeight: CGFloat!
    var activeField: UITextField?
    var tripId: String! {
        didSet {
            messageRef = Database.database().reference().child("trip_action").child(tripId)
            self.observeNewMessages()
        }
    }
    var messageRef: DatabaseReference?
    var messageRefHandle: DatabaseHandle?
    var currentAccount: Account?
    var actions = [TripAction]()
    
    @IBAction func onBackScr(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        editingChanged(messageTextField)
        
        bottomHeight = messageTextFieldBottomConstraint.constant
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        addDoneButton(to: messageTextField)
        let user = Auth.auth().currentUser
        if let user = user {
            currentAccount = Account(user: user)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSend(_ sender: UIButton) {
        sendMessage()
    }
    
    deinit {
        if let refHandle = messageRefHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
    }
}

extension ActionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action = actions[indexPath.row]
        if (action.member?.accountId == currentAccount?.accountId){
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatMeCell") as! ChatMeCell
            cell.action = action
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatOtherCell") as! ChatOtherCell
            cell.action = action
            return cell
        }
        
    }
}

extension ActionViewController {
    
    func sendMessage(){
        if let msg = messageTextField?.text{
            var message: TripAction?
            if msg == "" {
                message = TripAction(member: currentAccount!, type: .buzz, message: nil, messageUrl: nil)
            } else {
                message = TripAction(member: currentAccount!, type: .text, message: msg, messageUrl: nil)
            }
            FirebaseClient.sharedInstance.sendAction(tripId: tripId, action: message!, completion: { (error: Error?) in
                if let error = error {
                    print (error)
                } else {
                    
                }
            })
            self.messageTextField.text = ""
            editingChanged(messageTextField)
        }
    }
    
    func observeNewMessages() {
        
        messageRefHandle = messageRef?.observe(.childAdded, with: { (snapshot) in
            
            let messageDict = snapshot.value as? [String: Any]
            
            if let msgData = messageDict {
                let action = TripAction(dictionary: msgData)
                self.actions.append(action)
                
                if (self.tableView != nil){
                    self.tableView.reloadData()
                    let ip = NSIndexPath(row: self.actions.count-1, section: 0) as IndexPath
                    self.tableView.scrollToRow(at: ip, at: UITableViewScrollPosition.top, animated: true)
                }
            } else {
                print("Error! Could not decode message data")
            }
            
        })
    }
}

extension ActionViewController {
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        if let userInfo = notification.userInfo {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            
            messageTextFieldBottomConstraint.constant += (keyboardSize?.height)!
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
            
            if (self.tableView != nil){
                self.tableView.reloadData()
                let ip = NSIndexPath(row: self.actions.count-1, section: 0) as IndexPath
                self.tableView.scrollToRow(at: ip, at: UITableViewScrollPosition.top, animated: true)
            }
        }
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        if let userInfo = notification.userInfo {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            
            messageTextFieldBottomConstraint.constant = bottomHeight
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        if let phoneNumber = messageTextField.text, phoneNumber.isEmpty {
            sendButton.backgroundColor = UIColor.init(rgb: 0xD8524F)
            sendButton.setTitle("   BUZZ   ", for: .normal)
        } else {
            sendButton.backgroundColor = UIColor.init(rgb: 0x3E75D2)
            sendButton.setTitle("   SEND   ", for: .normal)
        }
    }
}
