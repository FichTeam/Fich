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
    
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 100
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
    
    @IBAction func onBack(_ sender: UIBarButtonItem) {
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
        if let msg = messageTextField?.text {
            let message = TripAction(member: currentAccount!, type: ActionType.text, message: msg, messageUrl: nil)
            FirebaseClient.sharedInstance.sendAction(tripId: tripId, action: message, completion: { (error: Error?) in
                if let error = error {
                    print (error)
                } else {
                    self.messageTextField.text = ""
                }
            })
            
        }
    }
    
    func observeNewMessages() {
        
        messageRefHandle = messageRef?.observe(.childAdded, with: { (snapshot) in
            
            let messageDict = snapshot.value as? [String: Any]
            
            if let msgData = messageDict {
                let action = TripAction(dictionary: msgData)
                self.actions.append(action)
                
                self.tableView.reloadData()
                let ip = NSIndexPath(row: self.actions.count-1, section: 0) as IndexPath
                self.tableView.scrollToRow(at: ip, at: UITableViewScrollPosition.top, animated: true)
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
        //Need to calculate keyboard exact size due to Apple suggestions
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.5)
        messageTextFieldBottomConstraint.constant += (keyboardSize?.height)!
        UIView.commitAnimations()
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.4)
        messageTextFieldBottomConstraint.constant -= (keyboardSize?.height)!
        UIView.commitAnimations()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
}
