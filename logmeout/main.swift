//
//  main.swift
//  logmeout
//
//  Created by Dimetrio on 25.07.17.

import Foundation
import AppKit

class YubiWatcher: NSObject, USBEventDelegate, NSUserNotificationCenterDelegate {
    private var monitor: USBEventMonitor!
    private var cooldown: TimeInterval!
    private var last: Date!
    override init() {
        super.init()
        last = Date(timeIntervalSince1970: 0)
        cooldown = TimeInterval(60)
        monitor = USBEventMonitor(delegate: self)
    }
    
    func deviceAdded(_ device: io_object_t) {
        let title = "Device Added"
        let msg = device.name() ?? "<unknown>"
        print("title: \(title) message: \(msg)")
    }
    
    func deviceRemoved(_ device: io_object_t) {
        let title = "Device Removed"
        let msg = device.name() ?? "<unknown>"
        print("title: \(title) message: \(msg)")
        let current = Date()
        if ((device.name()?.range(of: "Yubikey")) != nil && current.timeIntervalSince(last) > cooldown ){
            NSWorkspace.shared.open(NSURL(fileURLWithPath: "/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app") as URL)
            last = current
        }
        else{
            print("Cooldown \(cooldown) is more than \(current.timeIntervalSince(last))")
        }
        
    }
}




print("Hello, World!")
let watcher = YubiWatcher()

CFRunLoopRun()

