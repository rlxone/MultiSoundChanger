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
    var volumeViewController: VolumeViewController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupApp()
    }
    
    func setupApp() {
        volumeViewController = self.loadViewFromStoryboard(name: "Main", identifier: "ViewControllerId") as? VolumeViewController
        createMenu()
    }
    
    func loadViewFromStoryboard(name: String, identifier: String) -> Any {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "ViewControllerId")
    }
    
    func createMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBar1Image")
            button.action = #selector(self.statusBarAction)
        }
        
        let menu = NSMenu()
        
        var item = NSMenuItem(title: "Volume:", action: #selector(self.menuItemAction), keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
        
        item = NSMenuItem(title: "asdsa", action: #selector(self.menuItemAction), keyEquivalent: "")
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
                item.state = NSOnState
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
                    volumeViewController?.selectedDevices = Audio.getAggregateDeviceSubDeviceList(deviceID: deviceID)
                } else {
                    volumeViewController?.selectedDevices = [deviceID]
                }
                Audio.setOutputDevice(newDeviceID: deviceID)
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

