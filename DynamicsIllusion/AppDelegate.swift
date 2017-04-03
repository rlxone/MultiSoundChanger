//
//  AppDelegate.swift
//  DynamicsIllusion
//
//  Created by sdd on 02.04.17.
//  Copyright © 2017 mityny. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupApp()
    }
    
    func setupApp() {
        createMenu()
    }
    
    func createMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarImage")
            button.action = #selector(self.statusBarAction)
        }
        let menu = NSMenu()
        let devices = Audio.getOutputDevices()
        for device in devices! {
            let item = NSMenuItem(title: device.value, action: #selector(self.itemAction), keyEquivalent: "q")
            menu.addItem(item)
        }
        statusItem.menu = menu
    }
    
    func itemAction(sender: AnyObject) {
        print("asd")
    }
    
    func statusBarAction(sender: AnyObject) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

