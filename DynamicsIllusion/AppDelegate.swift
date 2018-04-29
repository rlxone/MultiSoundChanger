//
//  AppDelegate.swift
//  DynamicsIllusion
//
//  Created by rlxone on 02.04.17.
//  Copyright © 2017 rlxone. All rights reserved.
//

import Cocoa
import AudioToolbox
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let devices = Audio.getOutputDevices()
    let selectedDevices = [AudioDeviceID]()
    var volumeViewController: VolumeViewController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupApp()
    }
    
    func setupApp() {
        volumeViewController = loadViewFromStoryboard(named: "Main", identifier: "VolumeViewControllerId") as? VolumeViewController
        createMenu()
    }
    
    func loadViewFromStoryboard(named: String, identifier: String) -> Any {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: named), bundle: nil)
        return storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: identifier))
    }
    
    func createMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name(rawValue: "StatusBar1Image"))
            button.action = #selector(self.statusBarAction)
        }
        
        let menu = NSMenu()
        
        var item = NSMenuItem(title: "Volume:", action: #selector(self.menuItemAction), keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
        
        item = NSMenuItem(title: "", action: #selector(self.menuItemAction), keyEquivalent: "")
        item.view = volumeViewController?.view
        menu.addItem(item)
        
        item = NSMenuItem(title: "Output Devices:", action: #selector(self.menuItemAction), keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
        
        let defaultDevice = Audio.getDefaultOutputDevice()
        
        for device in devices! {
            let item = NSMenuItem(title: device.value.truncate(length: 25, trailing: "..."), action: #selector(self.menuItemAction), keyEquivalent: "")
            item.tag = Int(device.key)
            if device.key == defaultDevice {
                item.state = NSControl.StateValue.on
                if Audio.isAggregateDevice(deviceID: defaultDevice) {
                    volumeViewController?.selectedDevices = Audio.getAggregateDeviceSubDeviceList(deviceID: defaultDevice)
                    for device in (volumeViewController?.selectedDevices!)! {
                        if Audio.isOutputDevice(deviceID: device) {
                            let volume = Audio.getDeviceVolume(deviceID: device).first! * 100
                            volumeViewController?.volumeSlider.floatValue = volume
                            volumeViewController?.changeStatusItemImage(value: volume)
                            break
                        }
                    }
                } else {
                    volumeViewController?.selectedDevices = [defaultDevice]
                    let volume = Audio.getDeviceVolume(deviceID: defaultDevice).first! * 100
                    volumeViewController?.volumeSlider.floatValue = volume
                    volumeViewController?.changeStatusItemImage(value: volume)
                }
            }
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        item = NSMenuItem(title: "Quit", action: #selector(self.menuQuitAction), keyEquivalent: "q")
        menu.addItem(item)
        
        statusItem.menu = menu
    }
    
    @objc func menuQuitAction() {
        NSApplication.shared.terminate(self)
        
    }
    
    @objc func menuItemAction(sender: NSMenuItem) {
        for item in (statusItem.menu?.items)! {
            if item == sender {
                if item.state == NSControl.StateValue.off {
                    item.state = NSControl.StateValue.on
                }
                let deviceID = AudioDeviceID(item.tag)
                if Audio.isAggregateDevice(deviceID: deviceID) {
                    volumeViewController?.selectedDevices = Audio.getAggregateDeviceSubDeviceList(deviceID: deviceID)
                } else {
                    volumeViewController?.selectedDevices = [deviceID]
                }
                Audio.setOutputDevice(newDeviceID: deviceID)
            } else {
                item.state = NSControl.StateValue.off
            }
        }
    }
    
    @objc func statusBarAction(sender: AnyObject) {
        print("you can update")
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return menuItem.isEnabled
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}

