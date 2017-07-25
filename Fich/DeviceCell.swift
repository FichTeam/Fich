//
//  DeviceCell.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/12/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift
import CoreBluetooth

class DeviceCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  
  var PairBtnPress: ((UITableViewCell) -> Void)?
  var AnimateBtnPress: ((UITableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  @IBAction func onPair(_ sender: UIButton) {
      PairBtnPress?(self)
    }
  @IBAction func onAnimate(_ sender: UIButton) {
      AnimateBtnPress?(self)

    }
}
