//
//  GestureController.swift
//  iOSProject WatchKit Extension
//
//  Created by TRAING Serey on 06/12/2018.
//  Copyright © 2018 AlkRox. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class GestureController: WKInterfaceController {

    @IBOutlet weak var brightnessSlider: WKInterfaceSlider!
    @IBOutlet weak var hueSlider: WKInterfaceSlider!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func sliderClicked(_ value: Float) {
        let session = WCSession.default
        guard session.isReachable else {
            return
        }
        session.sendMessage(["hue": value*10.0], replyHandler: {
            reply in
            print(reply)
        }, errorHandler: {
            e in
            print(e)
        })
    }
}
