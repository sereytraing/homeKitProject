//
//  InterfaceController.swift
//  iOSProject WatchKit Extension
//
//  Created by TRAING Serey on 24/11/2018.
//  Copyright © 2018 AlkRox. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let session = WCSession.default
        guard session.isReachable else {
            return
        }
        
        /*session.sendMessage([
            "app": "start"], replyHandler: { reply in print(reply) }) {
                (err) in
                print(err)
        }
        
        self.pushController(withName: "GestureController", context: nil)*/
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}