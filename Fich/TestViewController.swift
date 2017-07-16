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

class TestViewController: UIViewController {

  private let disposeBag = DisposeBag()
  
  var scannedPeripheral: ScannedPeripheral!
  var manager: BluetoothManager!
  private var connectedPeripheral: Peripheral?
  fileprivate var servicesList: [Service] = []

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
