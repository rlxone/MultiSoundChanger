//
//  StringExtensions.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 03.04.17.
//  Copyright © 2017 Dmitry Medyuho. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
