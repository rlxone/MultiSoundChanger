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

    private enum Symbol: String {
        case newLine = "\n"
    }
    
    private enum LoggerError: Error {
        case fileError(String)
        case dataError
    }
    
    private static var isFirstLog = true
    
    private static var bundleIdentifier: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            outPrint(symbol: .error, string: Constants.InnerMessages.bundleIdentifierError)
            fatalError(Constants.InnerMessages.bundleIdentifierError)
        }
        return bundleIdentifier
    }
    
    static func info(_ string: String) {
        outAndFilePrint(symbol: .info, string: string)
    }
    
    static func debug(_ string: String) {
        outAndFilePrint(symbol: .debug, string: string)
    }
    
    static func warning(_ string: String) {
        outAndFilePrint(symbol: .warning, string: string)
    }
    
    static func error(_ string: String) {
        outAndFilePrint(symbol: .error, string: string)
    }
    
    private static func getDebugLine(symbol: DebugSymbol, string: String) -> String {
        let symbol = DebugSymbol.info.rawValue
        let logDate = getLogDate()
        return "\(symbol) [\(logDate)] \(string)"
    }
    
    private static func outAndFilePrint(symbol: DebugSymbol, string: String) {
        outPrint(symbol: .error, string: string)
        do {
            try filePrint(symbol: .info, string: string)
        } catch let error {
            outPrint(symbol: .error, string: error.localizedDescription)
        }
    }
    
    private static func outPrint(symbol: DebugSymbol, string: String) {
        let line = getDebugLine(symbol: symbol, string: string)
        print(line)
    }
    
    private static func filePrint(symbol: DebugSymbol, string: String, filename: String = Constants.logFilename) throws {
        do {
            var directoryUrl = try FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            directoryUrl.appendPathComponent(bundleIdentifier)
            try createDirectoryIfNeeded(url: directoryUrl)
            let fileUrl = directoryUrl.appendingPathComponent(Constants.logFilename, isDirectory: false)
            let line = wrapNewLine(getDebugLine(symbol: symbol, string: string))
            try removeLogFileIfNeeded(url: fileUrl)
            try appendToFile(url: fileUrl, content: line)
        } catch let error {
            throw LoggerError.fileError(error.localizedDescription)
        }
    }
    
    private static func appendToFile(url: URL, content: String) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            let fileHandle = try FileHandle(forWritingTo: url)
            guard let data = content.data(using: .utf8) else {
                throw LoggerError.dataError
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } else {
            try content.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    private static func createDirectoryIfNeeded(url: URL) throws {
        guard !FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
    }
    
    private static func removeLogFileIfNeeded(url: URL) throws {
        guard isFirstLog else {
            return
        }
        isFirstLog = false
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        try FileManager.default.removeItem(at: url)
    }
    
    private static func wrapNewLine(_ string: String) -> String {
        return string + Symbol.newLine.rawValue
    }
    
    private static func getLogDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
