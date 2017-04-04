//
//  ViewController.swift
//  DynamicsIllusion
//
//  Created by rlxone on 02.04.17.
//  Copyright © 2017 rlxone. All rights reserved.
//

import Cocoa
import AudioToolbox

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
    
    func changeStatusItemImage(value: Float) {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        if value < 1 {
            appDelegate.statusItem.button?.image = NSImage(named: "StatusBar1Image")
        } else if value > 1 && value < 100 / 3 {
            appDelegate.statusItem.button?.image = NSImage(named: "StatusBar2Image")
        } else if value > 100 / 3 && value < 100 / 3 * 2 {
            appDelegate.statusItem.button?.image = NSImage(named: "StatusBar3Image")
        } else if value > 100 / 3 * 2 && value <= 100 {
            appDelegate.statusItem.button?.image = NSImage(named: "StatusBar4Image")
        }
    }
    
    @IBAction func volumeSliderAction(_ sender: Any) {
        changeVolume(value: volumeSlider.floatValue / 100)
        changeStatusItemImage(value: volumeSlider.floatValue)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

