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

    @IBOutlet weak var hueSlider: WKInterfaceSlider!
    
    let session = WCSession.default
    let keyHue = "hue"
    let keyStop = "stop"
    let yesValue = "yes"
    var crownAccumulator = 0.0
    var hueValue: Int = 0 {
        didSet {
            if self.hueValue < 0 || self.hueValue > 36 {
                self.hueValue = oldValue
            }
            self.hueSlider.setValue(Float(self.hueValue))
            self.sendValue(value: self.hueValue)
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.crownSequencer.delegate = self
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
            guard self.session.isReachable else {
                return
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.crownSequencer.focus()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.sendLeaveController()
    }

    @IBAction func sliderClicked(_ value: Float) {
        self.sendValue(value: Int(value))
    }
    
    func sendValue(value: Int) {
        let val = Double(value) / 36
        self.hueSlider.setColor(UIColor.init(hue: CGFloat(val), saturation: 1.0, brightness: 1.0, alpha: 1.0))
        guard self.session.isReachable else {
            return
        }
        self.session.sendMessage([self.keyHue: value*10], replyHandler: {
            reply in
            //print(reply)
        }, errorHandler: {
            e in
            print(e)
        })
    }
    
    func sendLeaveController() {
        guard self.session.isReachable else {
            return
        }
        self.session.sendMessage([self.keyStop: self.yesValue], replyHandler: {
            reply in
            //print(reply)
        }, errorHandler: {
            e in
            print(e)
        })
    }
}

extension GestureController: WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        self.crownAccumulator += rotationalDelta
        if crownAccumulator > 0.1 {
            self.hueValue += 1
            self.crownAccumulator = 0.0
        } else if crownAccumulator < -0.1 {
            self.hueValue -= 1
            self.crownAccumulator = 0.0
        }
    }
}

extension GestureController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch OK \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler(["response": "envoyé depuis watch"])
        if let value = message[self.keyStop] as? String {
            switch value {
            case self.yesValue:
                self.pop()
                break
            default:
                break
            }
        }
    }
}
