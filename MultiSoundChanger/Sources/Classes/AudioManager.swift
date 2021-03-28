//
//  AudioManager.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 15.11.2020.
//  Copyright © 2020 Dmitry Medyuho. All rights reserved.
//

import AudioToolbox
import Foundation

// MARK: - Protocols

protocol AudioManager {
    func getDefaultOutputDevice() -> AudioDeviceID
    func getOutputDevices() -> [AudioDeviceID: String]?
    func selectDevice(deviceID: AudioDeviceID)
    func getSelectedDeviceVolume() -> Float?
    func setSelectedDeviceVolume(masterChannelLevel: Float, leftChannelLevel: Float, rightChannelLevel: Float)
    func isSelectedDeviceMuted() -> Bool
    func toggleMute()
    
    var isMuted: Bool { get }
}

// MARK: - Implementation

final class AudioManagerImpl: AudioManager {
    private let audio: Audio = AudioImpl()
    private let devices: [AudioDeviceID: String]?
    private var selectedDevice: AudioDeviceID?
    
    init() {
        devices = audio.getOutputDevices()
    }
    
    func getDefaultOutputDevice() -> AudioDeviceID {
        return audio.getDefaultOutputDevice()
    }
    
    func getOutputDevices() -> [AudioDeviceID: String]? {
        return devices
    }
    
    func isAggregateDevice(deviceID: AudioDeviceID) -> Bool {
        return audio.isAggregateDevice(deviceID: deviceID)
    }
    
    func selectDevice(deviceID: AudioDeviceID) {
        selectedDevice = deviceID
        audio.setOutputDevice(newDeviceID: deviceID)
    }
    
    func getSelectedDeviceVolume() -> Float? {
        guard let selectedDevice = selectedDevice else {
            return nil
        }
        
        if audio.isAggregateDevice(deviceID: selectedDevice) {
            let aggregatedDevices = audio.getAggregateDeviceSubDeviceList(deviceID: selectedDevice)
            
            for device in aggregatedDevices {
                if audio.isOutputDevice(deviceID: device) {
                    return audio.getDeviceVolume(deviceID: device).first
                }
            }
        } else {
            return audio.getDeviceVolume(deviceID: selectedDevice).first
        }
        
        return nil
    }
    
    func setSelectedDeviceVolume(masterChannelLevel: Float, leftChannelLevel: Float, rightChannelLevel: Float) {
        guard let selectedDevice = selectedDevice else {
            return
        }
        
        let isMute = leftChannelLevel < 0.001 && rightChannelLevel < 0.001
        
        if audio.isAggregateDevice(deviceID: selectedDevice) {
            let aggregatedDevices = audio.getAggregateDeviceSubDeviceList(deviceID: selectedDevice)
            
            for device in aggregatedDevices {
                audio.setDeviceVolume(
                    deviceID: device,
                    masterChannelLevel: masterChannelLevel,
                    leftChannelLevel: leftChannelLevel,
                    rightChannelLevel: rightChannelLevel
                )
                audio.setDeviceMute(deviceID: device, isMute: isMute)
            }
        } else {
            audio.setDeviceVolume(
                deviceID: selectedDevice,
                masterChannelLevel: masterChannelLevel,
                leftChannelLevel: leftChannelLevel,
                rightChannelLevel: rightChannelLevel
            )
            audio.setDeviceMute(deviceID: selectedDevice, isMute: isMute)
        }
    }
    
    func setSelectedDeviceMute(isMute: Bool) {
        guard let selectedDevice = selectedDevice else {
            return
        }
        
        if audio.isAggregateDevice(deviceID: selectedDevice) {
            let aggregatedDevices = audio.getAggregateDeviceSubDeviceList(deviceID: selectedDevice)
            
            for device in aggregatedDevices {
                audio.setDeviceMute(deviceID: device, isMute: isMute)
            }
        } else {
            audio.setDeviceMute(deviceID: selectedDevice, isMute: isMute)
        }
    }
    
    func isSelectedDeviceMuted() -> Bool {
        guard let selectedDevice = selectedDevice else {
            return false
        }
        
        if audio.isAggregateDevice(deviceID: selectedDevice) {
            let aggregatedDevices = audio.getAggregateDeviceSubDeviceList(deviceID: selectedDevice)
            
            guard let device = aggregatedDevices.first else {
                return false
            }
            
            return audio.isDeviceMuted(deviceID: device)
        } else {
            return audio.isDeviceMuted(deviceID: selectedDevice)
        }
    }
    
    func toggleMute() {
        if isSelectedDeviceMuted() {
            setSelectedDeviceMute(isMute: false)
            let volume = getSelectedDeviceVolume() ?? 0
            setSelectedDeviceVolume(masterChannelLevel: volume, leftChannelLevel: volume, rightChannelLevel: volume)
        } else {
            setSelectedDeviceMute(isMute: true)
        }
    }
    
    var isMuted: Bool {
        return isSelectedDeviceMuted()
    }
}
