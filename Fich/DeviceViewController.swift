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
        }
        return cell
    }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let deviceVC = TestViewController(nibName: "TestViewController", bundle: nil)
    
      deviceVC.scannedPeripheral = peripheralsArray[indexPath.row]
      deviceVC.manager = manager
      present(deviceVC, animated: true, completion: nil)

  }
}

extension DeviceCell {
    func configure(with peripheral: ScannedPeripheral) {
        nameLabel.text = peripheral.advertisementData.localName ?? peripheral.peripheral.identifier.uuidString
        scannedPeripheral = peripheral
    }
}

