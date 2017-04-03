//
//  ViewController.swift
//  DynamicsIllusion
//
//  Created by sdd on 02.04.17.
//  Copyright © 2017 mityny. All rights reserved.
//

import Cocoa
import AudioToolbox

class ViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var devicesTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupController()
        justFun()
        devicesTableView.dataSource = self
        //print(try! getInputDevices().count)
    }
    
    func justFun() {
        var defaultOutputDeviceID = AudioDeviceID(0)
        //var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var propertyAudioDataSize = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        var thePropSize: UInt32 = 0
        
        let result = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAudioDataSize, 0, nil, &thePropSize)
        
        let theNumDevices = thePropSize / UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var theDeviceList = [AudioDeviceID](repeating: 0, count: Int(theNumDevices))
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAudioDataSize, 0, nil, &thePropSize, &theDeviceList)
        
        for item in theDeviceList {
            print(item)
        }
        
        AudioObjectGetPropertyData(theDeviceList[2], &propertyAudioDataSize, 0, nil, &thePropSize, &theDeviceList)
        
        propertyAudioDataSize = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioAggregateDevicePropertyActiveSubDeviceList),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        thePropSize = 4
        
        let err = AudioObjectGetPropertyData(AudioDeviceID(56), &propertyAudioDataSize, 0, nil, &thePropSize, &theDeviceList)
        
        print(theNumDevices)
    }
    
    func setupController() {
        devicesTableView.focusRingType = .none
        devicesTableView.backgroundColor = NSColor.clear
        devicesTableView.headerView = nil
    }
    
    func handle(_ errorCode: OSStatus) throws {
        if errorCode != kAudioHardwareNoError {
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(errorCode), userInfo: [NSLocalizedDescriptionKey : "CAError: \(errorCode)" ])
            NSApplication.shared().presentError(error)
            throw error
        }
    }
    
    func getInputDevices() throws -> [AudioDeviceID] {
        
        var inputDevices: [AudioDeviceID] = []
        
        // Construct the address of the property which holds all available devices
        var devicesPropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
        var propertySize = UInt32(0)
        
        // Get the size of the property in the kAudioObjectSystemObject so we can make space to store it
        try handle(AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &devicesPropertyAddress, 0, nil, &propertySize))
        
        // Get the number of devices by dividing the property address by the size of AudioDeviceIDs
        let numberOfDevices = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        
        // Create space to store the values
        var deviceIDs: [AudioDeviceID] = []
        for _ in 0 ..< numberOfDevices {
            deviceIDs.append(AudioDeviceID())
        }
        
        // Get the available devices
        try handle(AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &devicesPropertyAddress, 0, nil, &propertySize, &deviceIDs))
        
        // Iterate
        for id in deviceIDs {
            
            // Get the device name for fun
            var name: CFString = "" as CFString
            var propertySize = UInt32(MemoryLayout<CFString>.size)
            var deviceNamePropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyDeviceNameCFString, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
            try handle(AudioObjectGetPropertyData(id, &deviceNamePropertyAddress, 0, nil, &propertySize, &name))
            
            // Check the input scope of the device for any channels. That would mean it's an input device
            
            // Get the stream configuration of the device. It's a list of audio buffers.
            var streamConfigAddress = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration, mScope: kAudioDevicePropertyScopeOutput, mElement: 0)
            
            // Get the size so we can make room again
            try handle(AudioObjectGetPropertyDataSize(id, &streamConfigAddress, 0, nil, &propertySize))
            
            // Create a buffer list with the property size we just got and let core audio fill it
            let audioBufferList = AudioBufferList.allocate(maximumBuffers: Int(propertySize))
            try handle(AudioObjectGetPropertyData(id, &streamConfigAddress, 0, nil, &propertySize, audioBufferList.unsafeMutablePointer))
            
            // Get the number of channels in all the audio buffers in the audio buffer list
            var channelCount = 0
            for i in 0 ..< Int(audioBufferList.unsafeMutablePointer.pointee.mNumberBuffers) {
                print(audioBufferList.unsafeMutablePointer.pointee.mBuffers)
                channelCount = channelCount + Int(audioBufferList[i].mNumberChannels)
            }
            
            free(audioBufferList.unsafeMutablePointer)
            
            // If there are channels, it's an input device
            if channelCount > 0 {
                Swift.print("Found input device '\(name)' with \(channelCount) channels")
                inputDevices.append(id)
            }
        }
        
        return inputDevices
    }
    
    func changeVolume(deviceID: Int, value: Float) {
        var defaultOutputDeviceID = AudioDeviceID(deviceID)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let status1 = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID)
        
        print(status1.description)
        
        var volume = Float32(value / 100)
        let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwareServiceDeviceProperty_VirtualMasterVolume),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        let status2 = AudioHardwareServiceSetPropertyData(
            defaultOutputDeviceID,
            &volumePropertyAddress,
            0,
            nil,
            volumeSize,
            &volume)

        var propertyName = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioObjectPropertyName),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        let str = ""
        
//        let status3 = AudioObjectGetPropertyData(
//            AudioObjectID(kAudioObjectSystemObject),
//            &propertyName,
//            0,
//            nil,
//            &UInt32(MemoryLayout.size(ofValue: str)),
//            &str)
    }
    
    @IBAction func volumeSliderAction(_ sender: Any) {
        changeVolume(deviceID: 0, value: volumeSlider.floatValue)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

