//
//  ChatMeCell.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/31/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class ChatMeCell: UITableViewCell {

    @IBOutlet weak var mesageLabel: UILabelWithPadding!
    @IBOutlet weak var timeLabel: UILabel!
    
    let formatter = DateFormatter()
    
    var action: TripAction! {
        didSet {
            switch action.type! {
            case .text:
                mesageLabel.text = action.message
                mesageLabel.backgroundColor = UIColor.init(rgb: 0x3E75D2)
                break
            case .lost:
                mesageLabel.text = "I'm lost"
                mesageLabel.backgroundColor = UIColor.init(rgb: 0xD8524F)
                break
            case .bikeBroken:
                mesageLabel.text = "My bike is broken"
                mesageLabel.backgroundColor = UIColor.init(rgb: 0xD8524F)
                break
            case .buzz:
                mesageLabel.text = "BUZZ"
                mesageLabel.textColor = UIColor.white
                mesageLabel.backgroundColor = UIColor.init(rgb: 0xD8524F)
                break
            }
            mesageLabel.layer.masksToBounds = true
            mesageLabel.layer.cornerRadius = 7
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
