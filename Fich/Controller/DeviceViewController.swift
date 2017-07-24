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

  var scannedPeripheral: ScannedPeripheral!
  var selectedPeripheral: ScannedPeripheral!
  private var connectedPeripheral: Peripheral?

  private let disposeBag = DisposeBag()

  fileprivate var peripheralsArray: [ScannedPeripheral] = []
  fileprivate var servicesList: [Service] = []
  fileprivate var characteristicsList: [Characteristic] = []
  
  private var isAnimate = false



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
  private func ConnectAndDiscover(_ peripheral: ScannedPeripheral)
  {
    guard selectedPeripheral != nil else { return }
    manager.connect(selectedPeripheral.peripheral)
      .subscribe(onNext: { [weak self] in
        guard let `self` = self else { return }
        self.connectedPeripheral = $0
        self.discoverService(for: $0)
        }, onError: { [weak self] error in
          print(error)
      }).addDisposableTo(disposeBag)
    
    selectedPeripheral = nil
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

  func PlayAnimate(peripheral: ScannedPeripheral) {
      isAnimate = true
      self.ConnectAndDiscover(peripheral)
  }
  func PairDevice()
  {
    
  }
  private func discoverService(for peripheral: Peripheral) {
    peripheral.discoverServices(nil)
      .subscribe(onNext: { services in
        self.servicesList = services
        self.discoverServiceCB(servicesArr: self.servicesList)
      }).addDisposableTo(disposeBag)
  }
  private func discoverServiceCB(servicesArr: [Service])
  {
    // Discover Characteristic for each Service
    for serviceIdx in 1...servicesArr.count
    {
      self.discoverCharacteristic(for: servicesArr[serviceIdx-1])
    }
    
  }
  
  private func discoverCharacteristic(for service: Service) {
    service.discoverCharacteristics(nil)
      .subscribe(onNext: { characteristics in
        self.characteristicsList = characteristics
        self.discoverCharacteristicCB(characteristicArr: self.characteristicsList)

      }).addDisposableTo(disposeBag)
  }
  private func discoverCharacteristicCB(characteristicArr: [Characteristic])
  {
    // Subcribe every characteristic
    for charIdx in 1...characteristicArr.count
    {
      self.subcribeCharacteristic(characteristic: characteristicArr[charIdx-1])
    }
    
  }
  private func subcribeCharacteristic(characteristic: Characteristic)
  {
    characteristic.setNotifyValue(true).subscribe(onNext: { (characteristic) in
      //subcribe CB
      self.subcribeCharacteristicCB(characteristic: characteristic)
    }).addDisposableTo(self.disposeBag)
  }
  
  private func subcribeCharacteristicCB(characteristic: Characteristic)
  {
    if isAnimate {
      if (characteristic.uuid.uuidString == "3DDA0002-957F-7D4A-34A6-74696673696D")
      {
        let cmdString = "02F106"
        self.writeValueForCharacteristic(hexadecimalString: cmdString, characteristic: characteristic)
        isAnimate = false
      }
    }
  }
  fileprivate func writeValueForCharacteristic(hexadecimalString: String,characteristic: Characteristic) {
    print("char: \(characteristic.uuid.uuidString)")
    let hexadecimalData: Data = Data.fromHexString(string: hexadecimalString)
    let type: CBCharacteristicWriteType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
    characteristic.writeValue(hexadecimalData as Data, type: type)
      .subscribe(onNext: { [weak self] _ in
        print("send cmd already")
      }).addDisposableTo(disposeBag)
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
}

extension DeviceCell {
    func configure(with peripheral: ScannedPeripheral) {
        nameLabel.text = peripheral.advertisementData.localName ?? "No name"//peripheral.peripheral.identifier.uuidString
//        scannedPeripheral = peripheral
    }
}

