//
//  AppDiagnostics.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2026-11-08.
//


import Foundation
import UIKit
import Darwin

enum AppDiagnostics {

    static var report: String {
        let info = Bundle.main.infoDictionary ?? [:]
        
        let appName = info["CFBundleDisplayName"] as? String
                ?? info["CFBundleName"] as? String
                ?? "Unknown"
        let appVersion = info["CFBundleShortVersionString"] as? String
            ?? "Unknown"
        let build = info["CFBundleVersion"] as? String
            ?? "Unknown"

        let deviceType = deviceFamily
        let model = deviceModelIdentifier()

        return """
        App: \(appName), version \(appVersion)(\(build))
        Device: \(deviceType), \(deviceNames[model] ?? model), (hardware \(model))
        OS version: \(osVersion)
        """
    }

    private static var deviceFamily: String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return "iPhone"
        case .pad: return "iPad"
        case .mac: return "Mac"
        default: return "Other"
        }
    }

    private static func deviceModelIdentifier() -> String {
        #if targetEnvironment(simulator)
        return ProcessInfo.processInfo.environment[
            "SIMULATOR_MODEL_IDENTIFIER"
        ] ?? "Simulator"
        #else
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)

        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)

        return String(cString: machine)
        #endif
    }
    
    private static var osVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let number = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

        switch UIDevice.current.userInterfaceIdiom {
        case .phone, .pad:
            return "iOS \(number)"
        case .mac:
            return "macOS \(number)"
        default:
            return "\(ProcessInfo.processInfo.operatingSystemVersionString)"
        }
    }
    
    private static let deviceNames: [String: String] = [
        //iPhones
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone8,4": "iPhone SE (1st gen)",

        "iPhone9,1": "iPhone 7",
        "iPhone9,3": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus",
        "iPhone9,4": "iPhone 7 Plus",

        "iPhone10,1": "iPhone 8",
        "iPhone10,4": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus",
        "iPhone10,5": "iPhone 8 Plus",

        "iPhone10,3": "iPhone X",
        "iPhone10,6": "iPhone X",

        "iPhone11,8": "iPhone XR",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",

        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE (2nd gen)",

        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",

        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,6": "iPhone SE (3rd gen)",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",

        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",

        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",

        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",

        "iPhone18,1": "iPhone 17 Pro",
        "iPhone18,2": "iPhone 17 Pro Max",
        "iPhone18,3": "iPhone 17",
        "iPhone18,4": "iPhone Air",
        
        // iPads
        "iPad6,11": "iPad (5th gen)",
        "iPad6,12": "iPad (5th gen)",

        "iPad6,3": "iPad Pro 9.7-inch",
        "iPad6,4": "iPad Pro 9.7-inch",
        "iPad6,7": "iPad Pro 12.9-inch (1st gen)",
        "iPad6,8": "iPad Pro 12.9-inch (1st gen)",

        "iPad7,1": "iPad Pro 12.9-inch (2nd gen)",
        "iPad7,2": "iPad Pro 12.9-inch (2nd gen)",
        "iPad7,3": "iPad Pro 10.5-inch",
        "iPad7,4": "iPad Pro 10.5-inch",

        "iPad7,5": "iPad (6th gen)",
        "iPad7,6": "iPad (6th gen)",

        "iPad7,11": "iPad (7th gen)",
        "iPad7,12": "iPad (7th gen)",

        "iPad8,1": "iPad Pro 11-inch (1st gen)",
        "iPad8,2": "iPad Pro 11-inch (1st gen)",
        "iPad8,3": "iPad Pro 11-inch (1st gen)",
        "iPad8,4": "iPad Pro 11-inch (1st gen)",

        "iPad8,5": "iPad Pro 12.9-inch (3rd gen)",
        "iPad8,6": "iPad Pro 12.9-inch (3rd gen)",
        "iPad8,7": "iPad Pro 12.9-inch (3rd gen)",
        "iPad8,8": "iPad Pro 12.9-inch (3rd gen)",

        "iPad8,9": "iPad Pro 11-inch (2nd gen)",
        "iPad8,10": "iPad Pro 11-inch (2nd gen)",
        "iPad8,11": "iPad Pro 12.9-inch (4th gen)",
        "iPad8,12": "iPad Pro 12.9-inch (4th gen)",

        "iPad11,1": "iPad mini (5th gen)",
        "iPad11,2": "iPad mini (5th gen)",
        "iPad11,3": "iPad Air (3rd gen)",
        "iPad11,4": "iPad Air (3rd gen)",

        "iPad11,6": "iPad (8th gen)",
        "iPad11,7": "iPad (8th gen)",

        "iPad12,1": "iPad (9th gen)",
        "iPad12,2": "iPad (9th gen)",

        "iPad13,1": "iPad Air (4th gen)",
        "iPad13,2": "iPad Air (4th gen)",
        "iPad13,4": "iPad Pro 11-inch (3rd gen)",
        "iPad13,5": "iPad Pro 11-inch (3rd gen)",
        "iPad13,6": "iPad Pro 11-inch (3rd gen)",
        "iPad13,7": "iPad Pro 11-inch (3rd gen)",
        "iPad13,8": "iPad Pro 12.9-inch (5th gen)",
        "iPad13,9": "iPad Pro 12.9-inch (5th gen)",
        "iPad13,10": "iPad Pro 12.9-inch (5th gen)",
        "iPad13,11": "iPad Pro 12.9-inch (5th gen)",
        "iPad13,16": "iPad Air (5th gen)",
        "iPad13,17": "iPad Air (5th gen)",

        "iPad14,1": "iPad mini (6th gen)",
        "iPad14,2": "iPad mini (6th gen)",
        "iPad14,3": "iPad Pro 11-inch (4th gen)",
        "iPad14,4": "iPad Pro 11-inch (4th gen)",
        "iPad14,5": "iPad Pro 12.9-inch (6th gen)",
        "iPad14,6": "iPad Pro 12.9-inch (6th gen)",
        "iPad14,8": "iPad Air 11-inch (M2)",
        "iPad14,9": "iPad Air 11-inch (M2)",
        "iPad14,10": "iPad Air 13-inch (M2)",
        "iPad14,11": "iPad Air 13-inch (M2)",

        "iPad15,3": "iPad Air 11-inch (M3)",
        "iPad15,4": "iPad Air 11-inch (M3)",
        "iPad15,5": "iPad Air 13-inch (M3)",
        "iPad15,6": "iPad Air 13-inch (M3)",
        "iPad15,7": "iPad (A16)",
        "iPad15,8": "iPad (A16)",

        "iPad16,1": "iPad mini (A17 Pro)",
        "iPad16,2": "iPad mini (A17 Pro)",
        "iPad16,3": "iPad Pro 11-inch (M4)",
        "iPad16,4": "iPad Pro 11-inch (M4)",
        "iPad16,5": "iPad Pro 13-inch (M4)",
        "iPad16,6": "iPad Pro 13-inch (M4)"
    ]
}
