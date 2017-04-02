//
//  ViewController.swift
//  DynamicsIllusion
//
//  Created by sdd on 02.04.17.
//  Copyright © 2017 mityny. All rights reserved.
//

import Cocoa
import AudioToolbox

class ViewController: NSViewController {
    
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var devicesTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupController()
        justFun()
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
        
        var theDeviceList = [AudioDeviceID](repeating: 0, count: Int(thePropSize))
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAudioDataSize, 0, nil, &thePropSize, &theDeviceList)
        
        for item in theDeviceList {
            print(item)
        }
        
        print(theNumDevices)
    }
    
    func setupController() {
        devicesTableView.focusRingType = .none
        devicesTableView.backgroundColor = NSColor.clear
        devicesTableView.headerView = nil
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

