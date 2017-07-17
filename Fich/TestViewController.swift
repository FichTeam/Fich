//
//  TestViewController.swift
//  Fich
//
//  Created by Triet on 7/15/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift
import CoreBluetooth

class TestViewController: UIViewController {

  private let disposeBag = DisposeBag()
  
  var scannedPeripheral: ScannedPeripheral!
  var manager: BluetoothManager!
  private var connectedPeripheral: Peripheral?
  fileprivate var servicesList: [Service] = []
  fileprivate var characteristicsList: [Characteristic] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
      guard scannedPeripheral != nil else { return }
      manager.connect(scannedPeripheral.peripheral)
        .subscribe(onNext: { [weak self] in
          guard let `self` = self else { return }
          //          self.title = "Connected"
          //          self.activityIndicatorView.stopAnimating()
          self.connectedPeripheral = $0
          self.monitorDisconnection(for: $0)
          self.downloadServices(for: $0)
          }, onError: { [weak self] error in
            print(error)
        }).addDisposableTo(disposeBag)

    }

  
    private func monitorDisconnection(for peripheral: Peripheral) {
      manager.monitorDisconnection(for: peripheral)
        .subscribe(onNext: { [weak self] (peripheral) in
        let alert = UIAlertController(title: "Disconnected!", message: "Peripheral Disconnected", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self?.present(alert, animated: true, completion: nil)
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


  
    fileprivate func writeValueForCharacteristic(hexadecimalString: String,characteristic: Characteristic) {
      let hexadecimalData: Data = Data.fromHexString(string: hexadecimalString)
      let type: CBCharacteristicWriteType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
      characteristic.writeValue(hexadecimalData as Data, type: type)
        .subscribe(onNext: { [weak self] _ in
          
        }).addDisposableTo(disposeBag)
    }
    private func getCharacteristics(for service: Service) {
      service.discoverCharacteristics(nil)
        .subscribe(onNext: { characteristics in
          self.characteristicsList = characteristics
          // send command though a characteristic
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
        }).addDisposableTo(disposeBag)
    }
  
  @IBAction func onDismiss(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func onAnimate(_ sender: Any) {
    for indexService in 1...servicesList.count{
      print("service: \(self.servicesList[indexService-1].uuid.uuidString)")
      getCharacteristics(for: servicesList[indexService-1])
    }
    

  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
