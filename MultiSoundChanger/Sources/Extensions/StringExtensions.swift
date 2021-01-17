//
//  StringExtensions.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 03.04.17.
//  Copyright © 2017 Dmitry Medyuho. All rights reserved.
//

import Foundation

extension String {
    func truncate(length: Int, trailing: String = "…") -> String {
        if count > length {
            return String(prefix(length)) + trailing
        } else {
            return self
        }
    }
}
