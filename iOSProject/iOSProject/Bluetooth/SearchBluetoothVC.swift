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
    
    //Bluetooth
    var centralManager: CBCentralManager!
    var soundCaptorPeripheral: CBPeripheral!
    let soundCaptorCharacNotify = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    let soundCaptorName = "SoundCaptor"
    
    ///HomeKit
    var selectedAccessory: HMAccessory!
    var service: HMService?
    let keyHue = "hue"
    let keyStart = "start"
    let yesValue = "yes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //HomeKit
        for service in self.selectedAccessory.services {
            if service.serviceType == HMServiceTypeLightbulb {
                self.service = service
            }
        }
    }
    
    func initWatchConnect() {
        let session = WCSession.default
        guard session.isWatchAppInstalled, session.isReachable else {
            return
        }
        session.sendMessage([self.keyStart: self.yesValue], replyHandler: {
            reply in
            print(reply)
        }, errorHandler: {
            e in
            print(e)
        })
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func soundCaptorConvert(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else {
            return -1
        }
        let byteArray = [UInt8](characteristicData)
        let firstBitValue = byteArray[0] & 0xFF
        print(firstBitValue)
        return Int(byteArray[0])
    }
    
    func soundReceived(_ sound: Int) {
        self.nameLabel.text = String(sound)
        /*let tmp = CGFloat(CGFloat(sound) / 100.0)
        print("val formule: \(tmp)")
        self.connectedView.backgroundColor = UIColor(hue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)*/
        
        //HomeKit
        if let service = service {
            for charac in service.characteristics {
                //Brightness
                if charac.characteristicType == HMCharacteristicTypeBrightness {
                    if var value = charac.value as? Int {
                        value = sound
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
            self.centralManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == self.soundCaptorName {
            self.soundCaptorPeripheral = peripheral
            self.centralManager.stopScan()
            self.nameLabel.text = peripheral.name
            self.soundCaptorPeripheral.delegate = self
            self.centralManager.connect(self.soundCaptorPeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.initWatchConnect()
        self.loaderView.isHidden = true
        self.connectedView.isHidden = false
        self.soundCaptorPeripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchBluetoothVC: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case self.soundCaptorCharacNotify:
            let value = self.soundCaptorConvert(from: characteristic)
            self.soundReceived(value)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}

extension SearchBluetoothVC: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler(["response": "envoyé depuis iphone"])
        if let hue = message[self.keyHue] as? Double {
            if let service = service {
                for charac in service.characteristics {
                    //Color
                    if charac.characteristicType == HMCharacteristicTypeHue {
                        if var value = charac.value as? Int {
                            value = Int(hue)
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
}
