//
//  AppDelegate.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 02.04.17.
//  Copyright © 2017 Dmitry Medyuho. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let applicationController: ApplicationController = ApplicationControllerImp()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        applicationController.start()
    }
}
