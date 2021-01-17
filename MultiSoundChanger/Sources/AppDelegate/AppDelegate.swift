//
//  AppDelegate.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 02.04.17.
//  Copyright © 2017 Dmitry Medyuho. All rights reserved.
//

import Cocoa
import MediaKeyTap

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var audioManager: AudioManager = AudioManagerImpl()
    private lazy var mediaManager: MediaManager = MediaManagerImpl(delegate: self)
    private lazy var statusBarController: StatusBarController = StatusBarControllerImpl(audioManager: audioManager)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarController.createMenu()
        mediaManager.listenMediaKeyTaps()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Terminate app job
    }
}

extension AppDelegate: MediaManagerDelegate {
    func onMediaKeyTap(mediaKey: MediaKey) {
        guard let selectedDeviceVolume = audioManager.getSelectedDeviceVolume() else {
            return
        }
        
        let volumeStep: Float = 1 / Float(Constants.chicletsCount)
        var volume: Float = (selectedDeviceVolume / volumeStep).rounded() * volumeStep
        
        switch mediaKey {
        case .volumeUp:
            volume = (volume + volumeStep).clamped(to: 0...1)
            audioManager.setSelectedDeviceVolume(leftChannelLevel: volume, rightChannelLevel: volume)
            
        case .volumeDown:
            volume = (volume - volumeStep).clamped(to: 0...1)
            audioManager.setSelectedDeviceVolume(leftChannelLevel: volume, rightChannelLevel: volume)
            
        case .mute:
            audioManager.toggleMute()
            if audioManager.isSelectedDeviceMuted() {
                volume = 0
            } else {
                volume = audioManager.getSelectedDeviceVolume() ?? 0
            }
            
        default:
            break
        }
        
        let correctedVolume = volume * 100
        
        statusBarController.updateVolume(value: correctedVolume)
        mediaManager.showOSD(volume: correctedVolume, chicletsCount: Constants.chicletsCount)
    }
}
