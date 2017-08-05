//
//  DeviceSettingViewController.swift
//  Fich
//
//  Created by Tran Tien Tin on 8/6/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift
import CoreBluetooth

class DeviceSettingViewController: UIViewController {

    var isScanInProgress = false
    var scheduler: ConcurrentDispatchQueueScheduler!
    let manager = BluetoothManager(queue: .main)
    var scanningDisposable: Disposable?
    
    var peripheralsArray: [ScannedPeripheral] = []
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timerQueue = DispatchQueue(label: "com.polidea.rxbluetoothkit.timer")
        scheduler = ConcurrentDispatchQueueScheduler(queue: timerQueue)

        tableView.delegate = self
        tableView.dataSource = self
        
        let deviceId = UserDefaults.standard.string(forKey: "deviceId")
        if let deviceId  = deviceId {
            deviceLabel.text = deviceId
        } else {
            deviceLabel.text = ""
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopScanning()
    }

    @IBAction func onDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension DeviceSettingViewController {
    func stopScanning() {
        scanningDisposable?.dispose()
        isScanInProgress = false
    }
    
    func startScanning() {
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
    
    func addNewScannedPeripheral(_ peripheral: ScannedPeripheral) {
        print("scanned \(peripheral.advertisementData.localName)")
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

}

extension DeviceSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceSettingCell") as! DeviceSettingCell
        cell.delegate = self
        let peripheral = peripheralsArray[indexPath.row]
        cell.configure(with: peripheral)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeripheral = peripheralsArray[indexPath.row]
//        connectAndBlink(selectedPeripheral.peripheral)
        BleApi.sharedInstance.connectAndBlink(selectedPeripheral.peripheral)
    }
}

extension DeviceSettingViewController: DeviceSettingDelegate {
    func connectDevice(cell: DeviceSettingCell) {
        let ip = tableView.indexPath(for: cell)
        
        let peripheral = peripheralsArray[(ip?.row)!]
        let deviceId = peripheral.peripheral.identifier.uuidString
        UserDefaults.standard.setValue(deviceId, forKey: "deviceId")
        deviceLabel.text = deviceId
    }
}

extension DeviceSettingCell {
    func configure(with peripheral: ScannedPeripheral) {
        print()
        nameLabel.text = peripheral.peripheral.identifier.uuidString ?? "No name"
        //peripheral.peripheral.identifier.uuidString
        //        scannedPeripheral = peripheral
    }
}
