//
//  SettingCell.swift
//  Fich
//
//  Created by Triet on 8/8/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

protocol SettingButtonDelegate {
    func buttonPress(cell: SettingCell)}

class SettingCell: UITableViewCell {
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    var delegate: SettingButtonDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func buttonPress(_ sender: UIButton) {
        delegate.buttonPress(cell: self)
    }
}
