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
    case second = 33
    case third = 66
}

class VolumeViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet var volumeSlider: NSSlider!
    
    var selectedDevices: [AudioDeviceID]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //justFun()
    }
    
    func changeVolume(value: Float) {
        if selectedDevices != nil {
            for device in selectedDevices! {
                Audio.setDeviceVolume(deviceID: device, leftChannelLevel: value, rightChannelLevel: value)
            }
        }
    }
    
    @IBAction func volumeSliderAction(_ sender: Any) {
        changeVolume(value: volumeSlider.floatValue / 100)
        //let appDelegate = NSApplication.shared().delegate as! AppDelegate
        //appDelegate.statusItem.button?.image =
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

