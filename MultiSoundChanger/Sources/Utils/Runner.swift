//
//  Runner.swift
//  MultiSoundChanger
//
//  Created by Dmitry on 22.04.21.
//  Copyright © 2021 mityny. All rights reserved.
//

import Cocoa

enum Runner {
    @discardableResult
    static func shell(_ command: String) -> String? {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        guard let output = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return output
    }

    static func launchApplication(bundleIndentifier: String, options: NSWorkspace.LaunchOptions) {
        NSWorkspace.shared.launchApplication(
            withBundleIdentifier: bundleIndentifier,
            options: options,
            additionalEventParamDescriptor: nil,
            launchIdentifier: nil
        )
    }
}
