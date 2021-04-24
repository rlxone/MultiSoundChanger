//
//  Audio.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 03.04.17.
//  Copyright © 2017 Dmitry Medyuho. All rights reserved.
//

import AudioToolbox
import Cocoa
import Foundation

// MARK: - Protocols

protocol Audio {
    func getOutputDevices() -> [AudioDeviceID: String]?
    func isOutputDevice(deviceID: AudioDeviceID) -> Bool
    func getAggregateDeviceSubDeviceList(deviceID: AudioDeviceID) -> [AudioDeviceID]
    func isAggregateDevice(deviceID: AudioDeviceID) -> Bool
    func setDeviceVolume(deviceID: AudioDeviceID, masterChannelLevel: Float, leftChannelLevel: Float, rightChannelLevel: Float)
    func setDeviceMute(deviceID: AudioDeviceID, isMute: Bool)
    func setOutputDevice(newDeviceID: AudioDeviceID)
    func isDeviceMuted(deviceID: AudioDeviceID) -> Bool
    func getDeviceVolume(deviceID: AudioDeviceID) -> [Float]
    func getDefaultOutputDevice() -> AudioDeviceID
    func getDeviceTransportType(deviceID: AudioDeviceID) -> AudioDevicePropertyID
}

// MARK: - Implementation

final class AudioImpl: Audio {
    func getOutputDevices() -> [AudioDeviceID: String]? {
        var result: [AudioDeviceID: String] = [:]
        let devices = getAllDevices()
        
        for device in devices where isOutputDevice(deviceID: device) {
            result[device] = getDeviceName(deviceID: device)
        }
        
        return result
    }
    
    func isOutputDevice(deviceID: AudioDeviceID) -> Bool {
        var propertySize: UInt32 = 256
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        _ = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
        
        return propertySize > 0
    }
    
    func getAggregateDeviceSubDeviceList(deviceID: AudioDeviceID) -> [AudioDeviceID] {
        let subDevicesCount = getNumberOfSubDevices(deviceID: deviceID)
        var subDevices = [AudioDeviceID](repeating: 0, count: Int(subDevicesCount))
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioAggregateDevicePropertyActiveSubDeviceList),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        var subDevicesSize = subDevicesCount * UInt32(MemoryLayout<UInt32>.size)
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &subDevicesSize, &subDevices)
        
        return subDevices
    }
    
    func isAggregateDevice(deviceID: AudioDeviceID) -> Bool {
        let deviceType = getDeviceTransportType(deviceID: deviceID)
        return deviceType == kAudioDeviceTransportTypeAggregate
    }
    
    func isDeviceMuted(deviceID: AudioDeviceID) -> Bool {
        var mutedValue: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyMute),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        let status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &mutedValue)
        
        if status != noErr {
            return false
        }
        
        return mutedValue == 1
    }
    
    func setDeviceVolume(deviceID: AudioDeviceID, masterChannelLevel: Float, leftChannelLevel: Float, rightChannelLevel: Float) {
        var leftLevel = leftChannelLevel
        var rigthLevel = rightChannelLevel
        var masterLevel = masterChannelLevel
        
        var masterLevelPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyVolumeScalar),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(0)
        )
        
        var leftLevelPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyVolumeScalar),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(1)
        )
        
        var rightLevelPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyVolumeScalar),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(2)
        )
        
        var size = UInt32(0)
        
        AudioObjectGetPropertyDataSize(deviceID, &masterLevelPropertyAddress, 0, nil, &size)
        AudioObjectSetPropertyData(deviceID, &masterLevelPropertyAddress, 0, nil, size, &masterLevel)
        
        AudioObjectGetPropertyDataSize(deviceID, &leftLevelPropertyAddress, 0, nil, &size)
        AudioObjectSetPropertyData(deviceID, &leftLevelPropertyAddress, 0, nil, size, &leftLevel)
        
        AudioObjectGetPropertyDataSize(deviceID, &rightLevelPropertyAddress, 0, nil, &size)
        AudioObjectSetPropertyData(deviceID, &rightLevelPropertyAddress, 0, nil, size, &rigthLevel)
    }
    
    func setDeviceMute(deviceID: AudioDeviceID, isMute: Bool) {
        var mutedValue: UInt32 = isMute ? 1 : 0
        let propertySize = UInt32(MemoryLayout<UInt32>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyMute),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectSetPropertyData(deviceID, &propertyAddress, 0, nil, propertySize, &mutedValue)
    }
    
    func setOutputDevice(newDeviceID: AudioDeviceID) {
        let propertySize = UInt32(MemoryLayout<UInt32>.size)
        var deviceID = newDeviceID
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, propertySize, &deviceID)
    }
    
    func getDeviceVolume(deviceID: AudioDeviceID) -> [Float] {
        var leftLevel = Float32(0)
        var rigthLevel = Float32(0)
        var masterLevel = Float32(0)
        
        var masterLevelPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyVolumeScalar),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(0)
        )
        
        var leftLevelPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyVolumeScalar),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(1)
        )
        
        var rightLevelPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyVolumeScalar),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(2)
        )
        
        var size = UInt32(0)
        
        AudioObjectGetPropertyDataSize(deviceID, &masterLevelPropertyAddress, 0, nil, &size)
        AudioObjectGetPropertyData(deviceID, &masterLevelPropertyAddress, 0, nil, &size, &masterLevel)
        
        AudioObjectGetPropertyDataSize(deviceID, &leftLevelPropertyAddress, 0, nil, &size)
        AudioObjectGetPropertyData(deviceID, &leftLevelPropertyAddress, 0, nil, &size, &leftLevel)
        
        AudioObjectGetPropertyDataSize(deviceID, &rightLevelPropertyAddress, 0, nil, &size)
        AudioObjectGetPropertyData(deviceID, &rightLevelPropertyAddress, 0, nil, &size, &rigthLevel)
        
        return [masterLevel, leftLevel, rigthLevel]
    }
    
    func getDefaultOutputDevice() -> AudioDeviceID {
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var deviceID = kAudioDeviceUnknown
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceID)
        
        return deviceID
    }
    
    func getDeviceTransportType(deviceID: AudioDeviceID) -> AudioDevicePropertyID {
        var deviceTransportType = AudioDevicePropertyID()
        var propertySize = UInt32(MemoryLayout<AudioDevicePropertyID>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyTransportType),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &deviceTransportType)
        
        return deviceTransportType
    }
    
    private func getNumberOfDevices() -> UInt32 {
        var propertySize: UInt32 = 0
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
        
        return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
    }
    
    private func getNumberOfSubDevices(deviceID: AudioDeviceID) -> UInt32 {
        var propertySize: UInt32 = 0
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioAggregateDevicePropertyActiveSubDeviceList),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        _ = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
        
        return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
    }
    
    private func getDeviceName(deviceID: AudioDeviceID) -> String {
        var propertySize = UInt32(MemoryLayout<CFString>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        var result: CFString = "" as CFString
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &result)
        
        return result as String
    }
    
    private func getDeviceType(deviceID: AudioDeviceID) -> String {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDataSourceNameForIDCFString),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        var sourceID: UInt32 = 0
        var result: CFString = "" as CFString
        
        var translation = AudioValueTranslation(
            mInputData: withUnsafeMutablePointer(to: &sourceID) { pointer in pointer },
            mInputDataSize: UInt32(MemoryLayout<UInt32>.size),
            mOutputData: withUnsafeMutablePointer(to: &result) { pointer in pointer },
            mOutputDataSize: UInt32(MemoryLayout<CFString>.size)
        )
        
        var propertySize = UInt32(MemoryLayout<AudioValueTranslation>.size)
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &translation)
        
        return result as String
    }
    
    private func getAllDevices() -> [AudioDeviceID] {
        let devicesCount = getNumberOfDevices()
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
