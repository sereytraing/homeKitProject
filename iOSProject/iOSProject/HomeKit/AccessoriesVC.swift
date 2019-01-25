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

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectedHome: HMHome!
    var lightBulbAccessories: [HMAccessory] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.selectedHome.name
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //Use custom cell from xib
        self.tableView.register(UINib(nibName: self.cellAccessoryName, bundle: nil), forCellReuseIdentifier: self.cellAccessoryName)
        self.backView.layer.cornerRadius = 15.0
        self.addView.layer.cornerRadius = 15.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getLightBulb()
        self.tableView.reloadData()
    }
    
    func getLightBulb() {
        //Check accessories(type: light bulb) to show, and refresh each time we go on the controller
        self.lightBulbAccessories = []
        for accessory in self.selectedHome.accessories {
            for service in accessory.services {
                if service.serviceType == HMServiceTypeLightbulb && accessory.isReachable {
                    self.lightBulbAccessories.append(accessory)
                }
            }
        }
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addClicked(_ sender: Any) {
        if let searchAccessoriesVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchAccessoriesVC") as? SearchAccessoriesVC {
            searchAccessoriesVC.selectedHome = self.selectedHome
            self.navigationController?.pushViewController(searchAccessoriesVC, animated: true)
        }
    }
}

extension AccessoriesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lightBulbAccessories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellAccessoryName, for: indexPath) as! CellAccesory
        cell.bindData(title: self.lightBulbAccessories[indexPath.row].name)
        return cell
    }
}

extension AccessoriesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let acc = self.lightBulbAccessories[indexPath.row]
            self.selectedHome.removeAccessory(acc) {
                err in
                self.getLightBulb()
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if let searchBluetooth = UIStoryboard.init(name: "Bluetooth", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchBluetoothVC") as? SearchBluetoothVC {
            searchBluetooth.selectedAccessory = self.lightBulbAccessories[indexPath.row]
            self.navigationController?.pushViewController(searchBluetooth, animated: true)
        }
    }
}
