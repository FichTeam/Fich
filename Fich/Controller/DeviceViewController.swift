//
//  DeviceViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/12/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift
import CoreBluetooth

class DeviceViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var isScanInProgress = false
    private var scheduler: ConcurrentDispatchQueueScheduler!
    let manager = BluetoothManager(queue: .main)
    private var scanningDisposable: Disposable?
    fileprivate var peripheralsArray: [ScannedPeripheral] = []
    var scannedPeripheral: ScannedPeripheral!
    var selectedPeripheral: ScannedPeripheral!
    private let disposeBag = DisposeBag()
    private var connectedPeripheral: Peripheral?
    fileprivate var servicesList: [Service] = []
    fileprivate var characteristicsList: [Characteristic] = []
  
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let timerQueue = DispatchQueue(label: "com.polidea.rxbluetoothkit.timer")
        scheduler = ConcurrentDispatchQueueScheduler(queue: timerQueue)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "deviceCell")
    }

    private func stopScanning() {
        scanningDisposable?.dispose()
        isScanInProgress = false
    }
    
    private func startScanning() {
        isScanInProgress = true
        scanningDisposable = manager.rx_state
            .timeout(4.0, scheduler: scheduler)
            .take(1)
            .flatMap { _ in self.manager.scanForPeripherals(withServices: nil, options:nil) }
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.addNewScannedPeripheral($0)
            }, onError: { error in
            })
    }
    
    
    private func addNewScannedPeripheral(_ peripheral: ScannedPeripheral) {
        let mapped = peripheralsArray.map { $0.peripheral }
        if let indx = mapped.index(of: peripheral.peripheral) {
            peripheralsArray[indx] = peripheral
        } else {
            self.peripheralsArray.append(peripheral)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func onBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func onScan(_ sender: UIButton) {
        if isScanInProgress {
            stopScanning()
            sender.setTitle("Start Scan", for: .normal)
        } else {
            startScanning()
            sender.setTitle("Stop Scan", for: .normal)
        }
    }
    func printst(text: NSString)  {
      print(text)
    }
  
  func PlayAnimate(peripheral: ScannedPeripheral) {
        guard selectedPeripheral != nil else { return }
        manager.connect(selectedPeripheral.peripheral)
          .subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
    
            self.connectedPeripheral = $0
//            self.monitorDisconnection(for: $0)
            self.downloadServices(for: $0)
//            self.PlayAnimate()
            }, onError: { [weak self] error in
              print(error)
          }).addDisposableTo(disposeBag)
  }
  private func downloadServices(for peripheral: Peripheral) {
    peripheral.discoverServices(nil)
      .subscribe(onNext: { services in
        self.servicesList = services
        for abc in 1...self.servicesList.count{
          print(self.servicesList[abc-1].uuid.uuidString)
        
        }
        self.playAnimate()
        print(self.servicesList)
      }).addDisposableTo(disposeBag)
  }
  private func playAnimate()
  {
    for serviceidx in 1...self.servicesList.count{
      if (servicesList[serviceidx-1].uuid.uuidString == "3DDA0001-957F-7D4A-34A6-74696673696D" )
      {
        getCharacteristics(for: servicesList[serviceidx-1])
      }
    }
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

  func PairDevice()
  {
  
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
}

extension DeviceViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        let peripheral = peripheralsArray[indexPath.row]
        if let deviceCell = cell as? DeviceCell {
            deviceCell.configure(with: peripheral)
            deviceCell.PairBtnPress = { [weak self] (cell) in
              self?.selectedPeripheral = self?.peripheralsArray[indexPath.row]
              self?.PairDevice()
            }
            deviceCell.AnimateBtnPress = { [weak self] (cell) in
              self?.selectedPeripheral = self?.peripheralsArray[indexPath.row]
              self?.PlayAnimate( peripheral: (self?.selectedPeripheral)!)
            }

        }
      return cell
    }
  func discoverServiceSuccesscb()
  {
    
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

  }
  

}

extension DeviceCell {
    func configure(with peripheral: ScannedPeripheral) {
        nameLabel.text = peripheral.advertisementData.localName ?? "No name"//peripheral.peripheral.identifier.uuidString
//        scannedPeripheral = peripheral
    }
}

