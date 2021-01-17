//
//  Stories.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 15.11.2020.
//  Copyright © 2020 Dmitry Medyuho. All rights reserved.
//

import Cocoa

enum Stories: String {
    case main = "Main"
    case volume = "Volume"
}

extension Stories {
    func controller<T: NSViewController>(_ classType: T.Type) -> T {
        let storyboard = NSStoryboard(name: rawValue, bundle: nil)
        let identifier = String(describing: classType)
        
        guard let controller = storyboard.instantiateController(withIdentifier: identifier) as? T else {
            fatalError("Wrong controller identifier")
        }
        
        return controller
    }
}
