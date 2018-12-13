//
//  SearchBluetoothVC.swift
//  iOSProject
//
//  Created by TRAING Serey on 07/12/2018.
//  Copyright © 2018 AlkRox. All rights reserved.
//

import UIKit
import CoreBluetooth
import HomeKit
import WatchConnectivity

class SearchBluetoothVC: DefaultVC {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var connectedView: UIView!
    @IBOutlet weak var loaderView: UIView!
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    let heartRateServiceCBUUID = CBUUID(string: "E4ABED4F-0FD2-1382-C991-1374801BB8C1")
    let heartRateService = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let heartRateCharacNotify = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    ///HomeKit
    var selectedAccessory: HMAccessory!
    var service: HMService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //HomeKit
        for service in self.selectedAccessory.services {
            if service.serviceType == HMServiceTypeLightbulb {
                self.service = service
            }
        }
        
        //Watch
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0xFF
        print(firstBitValue)
        return Int(byteArray[0])
        
        /*if firstBitValue == 0 {
         // Heart Rate Value Format is in the 2nd byte
         return Int(byteArray[1])
         } else {
         // Heart Rate Value Format is in the 2nd and 3rd bytes
         return (Int(byteArray[1]) << 8) + Int(byteArray[2])
         }*/
    }
    
    func onHeartRateReceived(_ heartRate: Int) {
        self.nameLabel.text = String(heartRate)
        let tmp = CGFloat(CGFloat(heartRate) / 100.0)
        print("val formule: \(tmp)")
        self.connectedView.backgroundColor = UIColor(hue: tmp, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        //print("BPM: \(heartRate)")
        
        
        //HomeKit
        if let service = service {
            for charac in service.characteristics {
                if charac.characteristicType == HMCharacteristicTypeHue {
                    if var value = charac.value as? Int {
                        value = Int(Double(heartRate)*3.6)
                        charac.writeValue(value) {
                            err in
                            print(err)
                        }
                    }
                }
                
                if charac.characteristicType == HMCharacteristicTypeBrightness {
                    if var value = charac.value as? Int {
                        value = heartRate
                        charac.writeValue(value) {
                            err in
                            print(err)
                        }
                    }
                }
            }
        }
        
        
    }
}

extension SearchBluetoothVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            //centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
            centralManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "MyHologramCommand" {
            self.heartRatePeripheral = peripheral
            centralManager.stopScan()
            self.nameLabel.text = peripheral.name
            heartRatePeripheral.delegate = self
            
            print(peripheral)
            centralManager.connect(heartRatePeripheral)
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        print(peripheral)
        self.loaderView.isHidden = true
        self.connectedView.isHidden = false
        //self.nameLabel.text = peripheral.name
        heartRatePeripheral.discoverServices(nil)
    }
}

extension SearchBluetoothVC: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
            print(service)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
            }
            
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case self.heartRateCharacNotify:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}

extension SearchBluetoothVC: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iPhone OK \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) { }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler(["response": "envoyé depuis iphone"])
        
        if let command = message["direction"] as? String {
            switch command {
            case "start":
                DispatchQueue.main.async {
                    //self.initGame()
                }
                break
                
            default:
                //self.direction = command
                break
            }
        }
    }
}
