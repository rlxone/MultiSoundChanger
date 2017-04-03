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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //justFun()
    }
    
    func changeVolume(deviceID: Int, value: Float) {
        
    }
    
    @IBAction func volumeSliderAction(_ sender: Any) {
        //changeVolume(deviceID: 0, value: volumeSlider.floatValue)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

