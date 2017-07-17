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

class DeviceCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
  private let disposeBag = DisposeBag()

  var scannedPeripheral: ScannedPeripheral!
  var manager: BluetoothManager!
  private var connectedPeripheral: Peripheral?
  fileprivate var servicesList: [Service] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onPair(_ sender: UIButton) {
      
      // Connect to device and discover service, notify if it's not a Fich device
      print("pair is pressed")

    }
  private func monitorDisconnection(for peripheral: Peripheral) {
    manager.monitorDisconnection(for: peripheral)
      .subscribe(onNext: { [weak self] (peripheral) in
//        let alert = UIAlertController(title: "Disconnected!", message: "Peripheral Disconnected", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        DeviceViewController?.present(alert, animated: true, completion: nil)
        print("disconnect")
      }).addDisposableTo(disposeBag)
  }
  
  private func downloadServices(for peripheral: Peripheral) {
    peripheral.discoverServices(nil)
      .subscribe(onNext: { services in
        self.servicesList = services
//        self.servicesTableView.reloadData()
        print(self.servicesList)
      }).addDisposableTo(disposeBag)
  }

}
