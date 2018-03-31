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
    @IBOutlet weak var mesageLabel: UILabelWithPadding!
    @IBOutlet weak var timeLabel: UILabel!
    
    let formatter = DateFormatter()
    
    var action: TripAction! {
        didSet {
            switch action.type! {
            case .text:
                mesageLabel.text = action.message
                mesageLabel.textColor = UIColor.darkText
                mesageLabel.backgroundColor = UIColor.init(rgb: 0xDDDDDD)
                break
            case .lost:
                mesageLabel.text = "I'm lost"
                mesageLabel.textColor = UIColor.white
                mesageLabel.backgroundColor = UIColor.init(rgb: 0xD8524F)
                break
            case .bikeBroken:
                mesageLabel.text = "My bike is broken"
                mesageLabel.textColor = UIColor.white
                mesageLabel.backgroundColor = UIColor.init(rgb: 0xD8524F)
                break
            case .buzz:
                mesageLabel.text = "BUZZ"
                mesageLabel.textColor = UIColor.white
                mesageLabel.backgroundColor = UIColor.init(rgb: 0xD8524F)
                break
            }
            if let ava = action.member?.avatar{
                if ava != ""{
                    avatarImage.setImageWith(URL(string: ava)!)
                }else{
                    avatarImage.image = UIImage(named: "noavatar")
                }
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
