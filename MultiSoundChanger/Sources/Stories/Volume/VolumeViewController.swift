//
//  ViewController.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 02.04.17.
//  Copyright © 2017 Dmitry Medyuho. All rights reserved.
//

import AudioToolbox
import Cocoa
import MediaKeyTap

final class VolumeViewController: NSViewController {
    @IBOutlet weak var volumeSlider: NSSlider!
    private var muted: Bool = false
    
    weak var statusBarController: StatusBarController?
    var audioManager: AudioManager?
    
    private func changeDeviceVolume(value: Float) {
        audioManager?.setSelectedDeviceVolume(leftChannelLevel: value, rightChannelLevel: value)
    }
    
    func updateSliderVolume(volume: Float) {
        volumeSlider.floatValue = volume.clamped(to: 0...100)
    }
    
    @IBAction func volumeSliderAction(_ sender: Any) {
        changeDeviceVolume(value: volumeSlider.floatValue / 100)
        print(volumeSlider.floatValue / 100)
        statusBarController?.changeStatusItemImage(value: volumeSlider.floatValue)
    }
}
