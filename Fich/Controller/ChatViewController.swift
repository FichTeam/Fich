//
//  ChatViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/31/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
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
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let user = Auth.auth().currentUser
        if let user = user {
            currentAccount = Account(user: user)
        }
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

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
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

extension ChatViewController {
    
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
