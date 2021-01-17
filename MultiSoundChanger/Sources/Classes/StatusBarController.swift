//
//  StatusBarController.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 15.11.2020.
//  Copyright © 2020 Dmitry Medyuho. All rights reserved.
//

import AudioToolbox
import Cocoa

// MARK: - Protocols

protocol StatusBarController: class {
    func createMenu()
    func changeStatusItemImage(value: Float)
    func updateVolume(value: Float)
}

// MARK: - Extensions

extension StatusBarControllerImpl {
    enum MenuItem {
        case volume
        case slider
        case output
        case separator
        case quit
    }
}

// MARK: - Implementation

final class StatusBarControllerImpl: StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let volumeController: VolumeViewController
    private let audioManager: AudioManager
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        
        self.volumeController = Stories.volume.controller(VolumeViewController.self)
        self.volumeController.audioManager = audioManager
        self.volumeController.statusBarController = self
    }
    
    func createMenu() {
        if let button = statusItem.button {
            button.image = Images.volumeImage1
        }
        
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        let volumeItem = getMenuItem(by: .volume)
        let sliderItem = getMenuItem(by: .slider)
        let outputItem = getMenuItem(by: .output)
        let separatorItem = getMenuItem(by: .separator)
        let quitItem = getMenuItem(by: .quit)
        
        menu.addItem(volumeItem)
        menu.addItem(sliderItem)
        menu.addItem(outputItem)
        setOutputDeviceList(for: menu)
        menu.addItem(separatorItem)
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    private func getMenuItem(by type: MenuItem) -> NSMenuItem {
        switch type {
        case .volume:
            let item = NSMenuItem(
                title: Strings.volume,
                action: nil,
                keyEquivalent: ""
            )
            item.isEnabled = false
            return item
            
        case .slider:
            let item = NSMenuItem(
                title: "",
                action: nil,
                keyEquivalent: ""
            )
            item.view = volumeController.view
            return item
            
        case .output:
            let item = NSMenuItem(
                title: Strings.output,
                action: nil,
                keyEquivalent: ""
            )
            item.isEnabled = false
            return item
            
        case .separator:
            return NSMenuItem.separator()
            
        case .quit:
            let item = NSMenuItem(
                title: Strings.quit,
                action: #selector(menuQuitAction),
                keyEquivalent: "q"
            )
            item.target = self
            return item
        }
    }
    
    private func setOutputDeviceList(for menu: NSMenu) {
        guard let devices = audioManager.getOutputDevices() else {
            return
        }
        
        let defaultDevice = audioManager.getDefaultOutputDevice()
        
        for device in devices {
            let item = NSMenuItem(
                title: device.value.truncate(length: 25),
                action: #selector(menuItemAction),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = Int(device.key)
            
            if device.key == defaultDevice {
                item.state = .on
                
                audioManager.selectDevice(deviceID: defaultDevice)
                
                guard let volume = audioManager.getSelectedDeviceVolume() else {
                    continue
                }
                
                let correctedVolume = volume * 100
                volumeController.updateSliderVolume(volume: correctedVolume)
                changeStatusItemImage(value: correctedVolume)
            }
            
            menu.addItem(item)
        }
    }
    
    func changeStatusItemImage(value: Float) {
        if value < 1 {
            statusItem.button?.image = Images.volumeImage1
        } else if value > 1 && value <= 100 / 3 {
            statusItem.button?.image = Images.volumeImage2
        } else if value > 100 / 3 && value <= 100 / 3 * 2 {
            statusItem.button?.image = Images.volumeImage3
        } else if value > 100 / 3 * 2 && value <= 100 {
            statusItem.button?.image = Images.volumeImage4
        }
    }
    
    func updateVolume(value: Float) {
        volumeController.updateSliderVolume(volume: value)
        changeStatusItemImage(value: value)
    }
    
    @objc
    private func menuItemAction(sender: NSMenuItem) {
        guard let items = statusItem.menu?.items else {
            return
        }
        for item in items {
            if item == sender {
                item.state = .on
                let deviceID = AudioDeviceID(item.tag)
                audioManager.selectDevice(deviceID: deviceID)
            } else {
                item.state = NSControl.StateValue.off
            }
        }
    }
    
    @objc
    private func menuQuitAction() {
        NSApplication.shared.terminate(self)
    }
}
