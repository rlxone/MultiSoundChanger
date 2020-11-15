//
//  StringExtensions.swift
//  DynamicsIllusion
//
//  Created by sdd on 03.04.17.
//  Copyright © 2017 rlxone. All rights reserved.
//

import Foundation

extension String {

    func truncate(length: Int, trailing: String = "…") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
}
