//
//  SimulateCell.swift
//  Fich
//
//  Created by Triet on 8/11/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

protocol SimulateDelegate {
  func update(isOnSimulate: Bool)
}

class SimulateCell: UITableViewCell {

  var delegate: SimulateDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  @IBAction func isChange(_ sender: UISwitch) {
    delegate.update(isOnSimulate: sender.isOn)
  }
}
