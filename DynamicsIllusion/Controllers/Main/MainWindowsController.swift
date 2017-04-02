//
//  MainWindowsController.swift
//  DynamicsIllusion
//
//  Created by sdd on 02.04.17.
//  Copyright © 2017 mityny. All rights reserved.
//

import Foundation
import Cocoa

class MainWindowsController: NSWindowController {
    
    var blurEffectView: NSVisualEffectView {
        let blurView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        blurView.blendingMode = NSVisualEffectBlendingMode.behindWindow
        blurView.material = NSVisualEffectMaterial.ultraDark
        blurView.state = NSVisualEffectState.active
        return blurView
    }
    
    override func windowDidLoad() {
        //self.window?.contentView?.addSubview(blurEffectView)
    }
    
}
