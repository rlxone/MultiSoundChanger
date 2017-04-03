//
//  StringExtensions.swift
//  DynamicsIllusion
//
//  Created by sdd on 03.04.17.
//  Copyright © 2017 mityny. All rights reserved.
//

import Foundation

extension String {

    func truncate(length: Int, trailing: String = "…") -> String {
        if self.characters.count > length {
            return String(self.characters.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
}
