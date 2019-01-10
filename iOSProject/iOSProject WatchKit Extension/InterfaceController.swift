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
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    
    let keyStart = "start"
    let yesValue = "yes"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        // Listen again for response if push->pop
        // In awake, can't reach session
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            guard session.isReachable else {
                return
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch OK \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {}

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler(["response": "envoyé depuis watch"])
        if let value = message[self.keyStart] as? String {
            switch value {
            case self.yesValue:
                self.pushController(withName: "GestureController", context: nil)
                break
            default:
                break
            }
        }
    }
}
