//
//  DeviceCell.swift
//  Fich
//
//  Created by Tran Tien Tin on 8/6/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit

protocol DeviceSettingDelegate {
    func connectDevice(cell: DeviceSettingCell)
}

class DeviceSettingCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    var delegate: DeviceSettingDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didConnectPress(_ sender: UIButton) {
        self.delegate.connectDevice(cell: self)
    }

}
