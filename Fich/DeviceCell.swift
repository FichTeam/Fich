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
  private let disposeBag = DisposeBag()

  var scannedPeripheral: ScannedPeripheral!
  var manager: BluetoothManager!
  private var connectedPeripheral: Peripheral?
  fileprivate var servicesList: [Service] = []
  fileprivate var characteristicsList: [Characteristic] = []

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
      
      // Connect to device and discover service, notify if it's not a Fich device
//      print("pair is pressed")

    }
  @IBAction func onAnimate(_ sender: UIButton) {
      AnimateBtnPress?(self)
//    print("Animate is pressed")
//    
//    guard scannedPeripheral != nil else { return }
//    manager.connect(scannedPeripheral.peripheral)
//      .subscribe(onNext: { [weak self] in
//        guard let `self` = self else { return }
// 
//        self.connectedPeripheral = $0
//        self.monitorDisconnection(for: $0)
//        self.downloadServices(for: $0)
//        self.playAnimate()
//        }, onError: { [weak self] error in
//          print(error)
//      }).addDisposableTo(disposeBag)
  }
  
  private func monitorDisconnection(for peripheral: Peripheral) {
    manager.monitorDisconnection(for: peripheral)
      .subscribe(onNext: { [weak self] (peripheral) in
        let alert = UIAlertController(title: "Disconnected!", message: "Peripheral Disconnected", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // TODO: device view controller should display a alert
        //DeviceViewController?.present(alert, animated: true, completion: nil)
        print("disconnect")
      }).addDisposableTo(disposeBag)
  }
  
  private func downloadServices(for peripheral: Peripheral) {
    peripheral.discoverServices(nil)
      .subscribe(onNext: { services in
        self.servicesList = services
        
        print(self.servicesList)
      }).addDisposableTo(disposeBag)
  }
  
  fileprivate func writeValueForCharacteristic(hexadecimalString: String,characteristic: Characteristic) {
    let hexadecimalData: Data = Data.fromHexString(string: hexadecimalString)
    let type: CBCharacteristicWriteType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
    characteristic.writeValue(hexadecimalData as Data, type: type)
      .subscribe(onNext: { [weak self] _ in
        print("send cmd already")
      }).addDisposableTo(disposeBag)
  }
  
  private func getCharacteristics(for service: Service) {
    service.discoverCharacteristics(nil)
      .subscribe(onNext: { characteristics in
        self.characteristicsList = characteristics
        // send command though a characteristic

      }).addDisposableTo(disposeBag)
  }
  private func playAnimate()
  {
    for serviceidx in 1...self.servicesList.count{
      if (servicesList[serviceidx-1].uuid.uuidString == "3DDA0001-957F-7D4A-34A6-74696673696D" )
      {
          getCharacteristics(for: servicesList[serviceidx-1])
          for indexCharacteristic in 1...self.characteristicsList.count{
          let cmpString = self.characteristicsList[indexCharacteristic-1].uuid.uuidString
          print("Char: \(cmpString)")
          if (cmpString == "3DDA0002-957F-7D4A-34A6-74696673696D")
          {
            // subcribe before write a cmd
            
            self.characteristicsList[indexCharacteristic-1].setNotifyValue(true)
              .subscribe(onNext: { [weak self] _ in
                let cmdString = "02F106"
                self?.writeValueForCharacteristic(hexadecimalString: cmdString, characteristic: (self?.characteristicsList[indexCharacteristic-1])!)
              }).addDisposableTo(self.disposeBag)
          }
        }
      }
    }
  }

}
