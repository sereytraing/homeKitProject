//
//  ObjectServicesVC.swift
//  iOSProject
//
//  Created by TRAING Serey on 24/11/2018.
//  Copyright © 2018 AlkRox. All rights reserved.
//

import UIKit
import HomeKit

class ObjectServicesVC: DefaultVC {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedAccessory: HMAccessory!
    var services: [HMService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.selectedAccessory.name
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        for service in self.selectedAccessory.services {
            if service.serviceType != HMServiceTypeAccessoryInformation {
                self.services.append(service)
            }
        }
    }
}

extension ObjectServicesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let characVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CharacVC") as? CharacVC {
            characVC.selectedService = self.services[indexPath.row]
            self.navigationController?.pushViewController(characVC, animated: true)
        }
    }
}

extension ObjectServicesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let service = self.services[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(service.name) -- \(service.serviceType)"
        return cell
    }
}
