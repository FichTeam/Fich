//
//  MemberCell.swift
//  Fich
//
//  Created by Tran Tien Tin on 8/1/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import AFNetworking

class MemberCell: UITableViewCell {

    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var leaderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var account: Account! {
        didSet {
            avatarImage.setImageWith(URL(string: account.avatar!)!)
            nameLabel.text = account.name
            phoneNumberLabel.text = account.phoneNumber
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didCallPress(_ sender: UIButton) {
    }
}
