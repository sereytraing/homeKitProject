//
//  HomeVC.swift
//  iOSProject
//
//  Created by TRAING Serey on 24/11/2018.
//  Copyright © 2018 AlkRox. All rights reserved.
//

import UIKit
import HomeKit
import WatchConnectivity

class HomeVC: DefaultVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addView: UIView!
    
    let homeManager = HMHomeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeManager.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: self.cellAccessoryName, bundle: nil), forCellReuseIdentifier: self.cellAccessoryName)
        self.addView.layer.cornerRadius = 15.0
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func addClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Créer une maison", message: nil, preferredStyle: .alert)
        alertController.addTextField { (txtField) in
            txtField.placeholder = "Nom de la maison"
        }
        alertController.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Créer", style: .default, handler: { (action) in
            guard let name = alertController.textFields?[0].text else {
                return
            }
            self.homeManager.addHome(withName: name, completionHandler: { (h, err) in
                self.tableView.reloadData()
            })
        }))
        self.present(alertController, animated: true)
    }
}

extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homeManager.homes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellAccessoryName, for: indexPath) as! CellAccesory
        cell.bindData(title: self.homeManager.homes[indexPath.row].name)
        cell.view.backgroundColor = UIColor.white
        return cell
    }
}

extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.homeManager.removeHome(self.homeManager.homes[indexPath.row]) { (err) in
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let accessoriesVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AccessoriesVC") as? AccessoriesVC {
            accessoriesVC.selectedHome = self.homeManager.homes[indexPath.row]
            self.navigationController?.pushViewController(accessoriesVC, animated: true)
        }
    }
}

extension HomeVC: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        self.tableView.reloadData()
    }
    
    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        self.tableView.reloadData()
    }
    
    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        self.tableView.reloadData()
    }
}
