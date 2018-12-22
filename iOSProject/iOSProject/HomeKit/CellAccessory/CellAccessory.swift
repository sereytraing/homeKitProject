//
//  CellAccessory.swift
//  iOSProject
//
//  Created by TRAING Serey on 22/12/2018.
//  Copyright © 2018 AlkRox. All rights reserved.
//

import UIKit

class CellAccesory: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 20.0
        self.containerView.layer.shadowColor = UIColor.black.cgColor
        self.containerView.layer.shadowOpacity = 0.2
        self.containerView.layer.shadowOffset = CGSize.zero
        self.containerView.layer.shadowRadius = 5
    }
    
    func bindData(title: String) {
        self.titleLabel.text = title
    }
}
