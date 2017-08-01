//
//  ChatOtherCell.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/31/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import AFNetworking

class ChatOtherCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var mesageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let formatter = DateFormatter()
    
    var member: Account?
    var action: TripAction! {
        didSet {
            switch action.type! {
            case ActionType.text:
                mesageLabel.text = action.message
                break
            case ActionType.lost:
                mesageLabel.text = "I'm lost"
                break
            case ActionType.bikeBroken:
                mesageLabel.text = "My bike is broken"
                break
            default:
                break
            }
            avatarImage.setImageWith(URL(string: (member?.avatar!)!)!)
            timeLabel.text = formatter.string(from: action.createdAt!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        formatter.dateFormat = "HH:mm"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
