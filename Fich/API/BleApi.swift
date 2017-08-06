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
    let manager = BluetoothManager(queue: .main)
    let disposeBag = DisposeBag()
    
    private init() {}
    
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
                _ = $0.value
            }).addDisposableTo(disposeBag)
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
}
