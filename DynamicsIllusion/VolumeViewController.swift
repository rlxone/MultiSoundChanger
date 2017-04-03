//
//  ViewController.swift
//  DynamicsIllusion
//
//  Created by sdd on 02.04.17.
//  Copyright © 2017 mityny. All rights reserved.
//

import Cocoa
import AudioToolbox

enum StatusBarImageProgress: Int {
    case none = 0
    case first = 1
    case second = 36
    case third = 72
}

class VolumeViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet var volumeSlider: NSSlider!
    
    var selectedDevices: [AudioDeviceID]?
    
    func changeVolume(value: Float) {
        if selectedDevices != nil {
            for device in selectedDevices! {
                Audio.setDeviceVolume(deviceID: device, leftChannelLevel: value, rightChannelLevel: value)
            }
        }
    }
    
    @IBAction func volumeSliderAction(_ sender: Any) {
        changeVolume(value: volumeSlider.floatValue / 100)
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        if volumeSlider.floatValue < Float(StatusBarImageProgress.first.rawValue) {
            appDelegate.statusItem.button?.image = NSImage(named: "StatusBar1Image")
        } else if volumeSlider.floatValue > Float(StatusBarImageProgress.first.rawValue) && volumeSlider.floatValue < Float(StatusBarImageProgress.second.rawValue) {
            appDelegate.statusItem.button?.image = NSImage(named: "StatusBar2Image")
        } else if volumeSlider.floatValue > Float(StatusBarImageProgress.second.rawValue) && volumeSlider.floatValue < Float(StatusBarImageProgress.third.rawValue) {
            appDelegate.statusItem.button?.image = NSImage(named: "StatusBar3Image")
        } else if volumeSlider.floatValue > Float(StatusBarImageProgress.second.rawValue) && volumeSlider.floatValue < 100 {
            appDelegate.statusItem.button?.image = NSImage(named: "StatusBar4Image")
        }
        //appDelegate.statusItem.button?.image =
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

