//
//  BleApi.swift
//  Fich
//
//  Created by Tran Tien Tin on 8/6/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import Foundation
import RxBluetoothKit
import RxSwift
import CoreBluetooth

class BleApi {
    
    static let sharedInstance = BleApi()
    
    let manager: BluetoothManager!
    let disposeBag = DisposeBag()
    private let FichService : CBUUID = CBUUID.init(string: "3DDA0001-957F-7D4A-34A6-74696673696D")
  
  
  
  private init() {
      manager = BluetoothManager(queue: .main)
    }
    
    func connectAndBlink(_ peripheral: Peripheral?){
        guard peripheral != nil else { return }
        peripheral!.connect()
            .flatMap { $0.discoverServices([CBUUID.init(string: "3DDA0001-957F-7D4A-34A6-74696673696D")]) }
            .flatMap { Observable.from($0) }
            .flatMap { $0.discoverCharacteristics([CBUUID.init(string: "3DDA0002-957F-7D4A-34A6-74696673696D")])}
            .flatMap { Observable.from($0) }
            .flatMap { $0.setNotifyValue(true)}
            .flatMap { Observable.from($0) }
            .flatMap { $0.writeValue(Data.fromHexString(string: "0A11"), type: .withResponse) }
            .subscribe(onNext: {
                print("write data success")
                self.disconnect(peripheral: peripheral!)
                _ = $0.value
              
            }).addDisposableTo(disposeBag)
      
    }
    func connect()
    {
      let deviceId = UserDefaults.standard.string(forKey: "deviceId")
      if let deviceId  = deviceId {
        manager.retrievePeripherals(withIdentifiers: [UUID.init(uuidString: deviceId)!])
          .flatMap { Observable.from($0) }
          .flatMap { $0.connect() }
          .flatMap { Observable.from($0) }
          .flatMap { $0.discoverServices([CBUUID.init(string: "3DDA0001-957F-7D4A-34A6-74696673696D")]) }
          .flatMap { Observable.from($0) }
          .flatMap { $0.discoverCharacteristics([CBUUID.init(string: "3DDA0002-957F-7D4A-34A6-74696673696D")])}
          .subscribe(onNext: { x in
            print("Connected")
          }).addDisposableTo(disposeBag)
      }

    }
    func blink() {
        let deviceId = UserDefaults.standard.string(forKey: "deviceId")
        if let deviceId  = deviceId {
            manager.retrievePeripherals(withIdentifiers: [UUID.init(uuidString: deviceId)!])
                .flatMap { Observable.from($0) }
                .flatMap { $0.connect() }
                .flatMap { Observable.from($0) }
                .flatMap { $0.discoverServices([CBUUID.init(string: "3DDA0001-957F-7D4A-34A6-74696673696D")]) }
                .flatMap { Observable.from($0) }
                .flatMap { $0.discoverCharacteristics([CBUUID.init(string: "3DDA0002-957F-7D4A-34A6-74696673696D")])}
                .flatMap { Observable.from($0) }
                .flatMap { $0.setNotifyValue(true)}
                .flatMap { Observable.from($0) }
                .flatMap { $0.writeValue(Data.fromHexString(string: "0A11"), type: .withResponse) }
                .subscribe(onNext: {
                    print("write data success")
                    _ = $0.value
                }).addDisposableTo(disposeBag)
        }
    }
    private func disconnect(peripheral: Peripheral)
    {
      peripheral.cancelConnection().subscribe(onNext: { peripheral in
      print("Disconnect to: \(peripheral)")})
    }
    func CheckAnyFichDeviceConnected() -> Int
    {
      
      var isComplete = false
      var numOfDevice = 0
      if (self.checkBTstate() == BluetoothState.poweredOn)
      {
        self.manager.retrieveConnectedPeripherals(withServices: [FichService]).subscribe(onNext: { peripheral in
          numOfDevice = peripheral.count
          isComplete = true
        }).addDisposableTo(disposeBag)
        while(!isComplete)
        {
          
        }
      }
      else
      {
        // pop up a message
      }
      print("num of connect device \(numOfDevice)")
      return numOfDevice
    }
  
    func checkBTstate() -> BluetoothState {
      let stateObservable = manager.state as BluetoothState
      switch stateObservable {
      case BluetoothState.unknown:
        print("unknown")
        break
      case BluetoothState.poweredOff:
        print("poweredOff")
        break
      case BluetoothState.poweredOn:
        print("poweredOn")
        break
      default:
        break
      }
      return stateObservable
    }
}
