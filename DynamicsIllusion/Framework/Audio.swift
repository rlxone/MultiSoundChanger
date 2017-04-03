//
//  Audio.swift
//  DynamicsIllusion
//
//  Created by sdd on 03.04.17.
//  Copyright © 2017 mityny. All rights reserved.
//

import Foundation
import Cocoa
import AudioToolbox

public class Audio {
    
    static func getOutputDevices() -> [AudioDeviceID: String]? {
        var result: [AudioDeviceID: String] = [:]
        let devices = getAllDevices()
        
        for device in devices {
            if isOutputDevice(deviceID: device) {
                result[device] = getDeviceName(deviceID: device)
            }
        }
        
        return result
    }
    
    private static func getNumberOfDevices() -> UInt32 {
        var propertySize: UInt32 = 0
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        _ = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
        
        return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
    }
    
    private static func isOutputDevice(deviceID: AudioDeviceID) -> Bool {
        var propertySize: UInt32 = 256
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        _ = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
        
        return propertySize > 0
    }
    
    private static func getDeviceName(deviceID: AudioDeviceID) -> String {
        var propertySize = UInt32(MemoryLayout<CFString>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        var result: CFString = "" as CFString
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &result)
        
        return result as String
    }
    
    private static func getAllDevices() -> [AudioDeviceID] {
        var devicesCount = getNumberOfDevices()
        var devices = [AudioDeviceID](repeating: 0, count: Int(devicesCount))
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        var devicesSize = devicesCount * UInt32(MemoryLayout<UInt32>.size)
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &devicesSize, &devices)
        
        return devices
    }
        
}
