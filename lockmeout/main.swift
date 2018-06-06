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
    func lockScreenImmediate() -> Void {
        // Note: Private -- Do not use!
        // http://stackoverflow.com/questions/34669958/swift-how-to-call-a-c-function-loaded-from-a-dylib
        
        let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
        let sym = dlsym(libHandle, "SACLockScreenImmediate")
        typealias myFunction = @convention(c) () -> Void
        let SACLockScreenImmediate = unsafeBitCast(sym, to: myFunction.self)
        SACLockScreenImmediate()
    }
    func deviceRemoved(_ device: io_object_t) {
        let title = "Device Removed"
        let msg = device.name() ?? "<unknown>"
        print("title: \(title) message: \(msg)")
        let current = Date()
        if ((device.name()?.range(of: "Yubikey")) != nil && current.timeIntervalSince(last) > cooldown ){
            //NSWorkspace.shared.open(NSURL(fileURLWithPath: "/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app") as URL)
            lockScreenImmediate()
            last = current
            print("Locked!")
        }
        else{
            print("Cooldown \(cooldown) is more than \(current.timeIntervalSince(last))")
        }
        
    }
}


let watcher = YubiWatcher()

CFRunLoopRun()

