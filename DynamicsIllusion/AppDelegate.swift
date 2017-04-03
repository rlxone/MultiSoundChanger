//
//  AppDelegate.swift
//  DynamicsIllusion
//
//  Created by sdd on 02.04.17.
//  Copyright © 2017 mityny. All rights reserved.
//

import Cocoa
import AudioToolbox

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let devices = Audio.getOutputDevices()
    let selectedDevices = [AudioDeviceID]()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupApp()
    }
    
    func setupApp() {
        createMenu()
    }
    
    func loadViewFromStoryboard(name: String, identifier: String) -> Any {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "ViewControllerId")
    }
    
    func createMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarImage")
            button.action = #selector(self.statusBarAction)
        }
        let menu = NSMenu()
        
        var item = NSMenuItem(title: "Volume:", action: #selector(self.menuItemAction), keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
        
        item = NSMenuItem(title: "asdsa", action: #selector(self.menuItemAction), keyEquivalent: "")
        let controller = loadViewFromStoryboard(name: "Main", identifier: "ViewControllerId") as! ViewController
        item.view = controller.view
        menu.addItem(item)
        
        item = NSMenuItem(title: "Output Devices:", action: #selector(self.menuItemAction), keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
        
        for device in devices! {
            let item = NSMenuItem(title: device.value.truncate(length: 25, trailing: "..."), action: #selector(self.menuItemAction), keyEquivalent: "")
            item.tag = Int(device.key)
            menu.addItem(item)
        }
        
        statusItem.menu = menu
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return menuItem.isEnabled
    }
    
    func menuItemAction(sender: NSMenuItem) {
        for item in (statusItem.menu?.items)! {
            if item == sender {
                if item.state == NSOffState {
                    item.state = NSOnState
                }
                let deviceID = AudioDeviceID(item.tag)
                if Audio.isAggregateDevice(deviceID: deviceID) {
                    print("aggregate!")
                    print(Audio.getAggregateDeviceSubDeviceList(deviceID: deviceID))
                } else {
                    print("not aggregate!")
                }
                
            } else {
                item.state = NSOffState
            }
        }
    }
    
    func statusBarAction(sender: AnyObject) {
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

