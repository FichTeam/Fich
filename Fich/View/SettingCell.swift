//
//  SettingCell.swift
//  Fich
//
//  Created by Triet on 8/8/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
