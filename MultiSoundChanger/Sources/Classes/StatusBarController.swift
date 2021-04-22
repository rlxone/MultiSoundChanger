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
        case soundPreferences
        case audioSetup
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
        let firstSeparatorItem = getMenuItem(by: .separator)
        let soundPreferencesItem = getMenuItem(by: .soundPreferences)
        let audioSetupItem = getMenuItem(by: .audioSetup)
        let secondSeparatorItem = getMenuItem(by: .separator)
        let quitItem = getMenuItem(by: .quit)
        
        menu.addItem(volumeItem)
        menu.addItem(sliderItem)
        menu.addItem(outputItem)
        setOutputDeviceList(for: menu)
        menu.addItem(firstSeparatorItem)
        menu.addItem(soundPreferencesItem)
        menu.addItem(audioSetupItem)
        menu.addItem(secondSeparatorItem)
        menu.addItem(quitItem)
        
        statusItem.menu = menu
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
    
    private func getMenuItem(by type: MenuItem) -> NSMenuItem {
        switch type {
        case .volume:
            let item = NSMenuItem(title: Strings.volume, action: nil, keyEquivalent: Constants.Keys.empty.rawValue)
            item.isEnabled = false
            return item
            
        case .slider:
            let item = NSMenuItem(title: String(), action: nil, keyEquivalent: Constants.Keys.empty.rawValue)
            item.view = volumeController.view
            return item
            
        case .output:
            let item = NSMenuItem(title: Strings.output, action: nil, keyEquivalent: Constants.Keys.empty.rawValue)
            item.isEnabled = false
            return item
            
        case .separator:
            return NSMenuItem.separator()
                
        case .soundPreferences:
            let item = NSMenuItem(
                title: Strings.soundPreferences,
                action: #selector(menuSoundPreferencesAction),
                keyEquivalent: Constants.Keys.empty.rawValue
            )
            item.target = self
            return item
            
        case .audioSetup:
            let item = NSMenuItem(title: Strings.audioDevices, action: #selector(menuAudioSetupAction), keyEquivalent: Constants.Keys.empty.rawValue)
            item.target = self
            return item
            
        case .quit:
            let item = NSMenuItem(title: Strings.quit, action: #selector(menuQuitAction), keyEquivalent: Constants.Keys.q.rawValue)
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
                title: truncate(device.value, length: Constants.optionMaxLength),
                action: #selector(menuItemAction),
                keyEquivalent: String()
            )
            item.target = self
            item.tag = Int(device.key)
            
            if device.key == defaultDevice {
                item.state = .on
                
                audioManager.selectDevice(deviceID: defaultDevice)
                
                guard let volume = audioManager.getSelectedDeviceVolume() else {
                    continue
                }
                
                let correctedVolume = audioManager.isMuted ? 0 : volume * 100
                volumeController.updateSliderVolume(volume: correctedVolume)
                changeStatusItemImage(value: correctedVolume)
            }
            
            menu.addItem(item)
        }
    }
    
    private func truncate(_ string: String, length: Int, trailing: String = "…") -> String {
        if string.count > length {
            return String(string.prefix(length)) + trailing
        } else {
            return string
        }
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
    private func menuSoundPreferencesAction() {
        Runner.shell("open -b \(Constants.AppBundleIdentifier.systemPreferences) \(Constants.SystemPreferencesPane.sound)")
    }
    
    @objc
    private func menuAudioSetupAction() {
        Runner.launchApplication(bundleIndentifier: Constants.AppBundleIdentifier.audioDevices, options: .default)
    }
    
    @objc
    private func menuQuitAction() {
        NSApplication.shared.terminate(self)
    }
}
