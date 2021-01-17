//
//  NumbersExtensions.swift
//  MultiSoundChanger
//
//  Created by Dmitry Medyuho on 22.11.2020.
//  Copyright © 2020 Dmitry Medyuho. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
