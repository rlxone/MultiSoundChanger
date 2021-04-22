//
//  Logger.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 20.04.21.
//  Copyright © 2021 Dmitry Medyuho. All rights reserved.
//

import Foundation

enum Logger {
    private enum DebugSymbol: String {
        case info = "🔵"
        case debug = "🟢"
        case warning = "🟠"
        case error = "🔴"
    }

    private enum LoggerError: Error {
        case fileError
        case dataError
    }
    
    static func info(_ string: String) {
        outPrint(symbol: .info, string: string)
        do {
            try filePrint(symbol: .info, string: string)
        } catch let error {
            outPrint(symbol: .error, string: error.localizedDescription)
        }
    }
    
    static func debug(_ string: String) {
        outPrint(symbol: .debug, string: string)
        do {
            try filePrint(symbol: .info, string: string)
        } catch let error {
            outPrint(symbol: .error, string: error.localizedDescription)
        }
    }
    
    static func warning(_ string: String) {
        outPrint(symbol: .warning, string: string)
        do {
            try filePrint(symbol: .info, string: string)
        } catch let error {
            outPrint(symbol: .error, string: error.localizedDescription)
        }
    }
    
    static func error(_ string: String) {
        outPrint(symbol: .error, string: string)
        do {
            try filePrint(symbol: .info, string: string)
        } catch let error {
            outPrint(symbol: .error, string: error.localizedDescription)
        }
    }
    
    private static func getLine(symbol: DebugSymbol, string: String) -> String {
        let symbol = DebugSymbol.info.rawValue
        let logDate = getLogDate()
        return "\(symbol) [\(logDate)] \(string)"
    }
    
    private static func outPrint(symbol: DebugSymbol, string: String) {
        let line = getLine(symbol: symbol, string: string)
        print(line)
    }
    
    private static func filePrint(symbol: DebugSymbol, string: String) throws {
        do {
            var logUrl = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            logUrl.appendPathComponent(bundleIdentifier)
            logUrl.appendPathComponent(Constants.logFilename)
            if FileManager.default.fileExists(atPath: logUrl.path) {
                let fileHandle = try FileHandle(forWritingTo: logUrl)
                let line = getLine(symbol: symbol, string: string) + "\n"
                guard let data = line.data(using: .utf8) else {
                    throw LoggerError.dataError
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                let line = getLine(symbol: symbol, string: string) + "\n"
                try line.write(to: logUrl, atomically: true, encoding: .utf8)
            }
        } catch {
            throw LoggerError.fileError
        }
    }
    
    private static var bundleIdentifier: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            outPrint(symbol: .error, string: Constants.InnerMessages.bundleIdentifierError)
            fatalError(Constants.InnerMessages.bundleIdentifierError)
        }
        return bundleIdentifier
    }
    
    private static func getLogDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
