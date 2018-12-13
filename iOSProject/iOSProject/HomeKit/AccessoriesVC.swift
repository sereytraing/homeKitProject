//
//  AccessoriesVC.swift
//  iOSProject
//
//  Created by TRAING Serey on 24/11/2018.
//  Copyright © 2018 AlkRox. All rights reserved.
//

import UIKit
import HomeKit

class AccessoriesVC: DefaultVC {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedHome: HMHome!
    var lightBulbAccessories: [HMAccessory] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.selectedHome.name
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(searchNewAccessories))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lightBulbAccessories = []
        for accessory in self.selectedHome.accessories {
            for service in accessory.services {
                if service.serviceType == HMServiceTypeLightbulb {
                    lightBulbAccessories.append(accessory)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    @objc func searchNewAccessories() {
        if let searchAccessoriesVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchAccessoriesVC") as? SearchAccessoriesVC {
            searchAccessoriesVC.selectedHome = self.selectedHome
            self.navigationController?.pushViewController(searchAccessoriesVC, animated: true)
        }
    }
}

extension AccessoriesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.selectedHome.accessories.count
        return self.lightBulbAccessories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.lightBulbAccessories[indexPath.row].name
        return cell
    }
}

extension AccessoriesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let acc = self.lightBulbAccessories[indexPath.row]
            self.selectedHome.removeAccessory(acc) {
                err in
                if err == nil {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*if let objectServiceVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ObjectServicesVC") as? ObjectServicesVC {
            objectServiceVC.selectedAccessory = self.lightBulbAccessories[indexPath.row]
            self.navigationController?.pushViewController(objectServiceVC, animated: true)
        }*/
        
        if let searchBluetooth = UIStoryboard.init(name: "Bluetooth", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchBluetoothVC") as? SearchBluetoothVC {
            searchBluetooth.selectedAccessory = self.lightBulbAccessories[indexPath.row]
            self.navigationController?.pushViewController(searchBluetooth, animated: true)
        }
        
        
    }
}
