//
//  ScrollableSlider.swift
//
//  Created by Nate Thompson on 10/24/17.
//
//  https://github.com/thompsonate/Scrollable-NSSlider
//

import Cocoa

class ScrollableSlider: NSSlider {
    override func scrollWheel(with event: NSEvent) {
        guard self.isEnabled else {
            return
        }
        
        let range = Float(self.maxValue - self.minValue)
        var delta = Float(0)
        
        // Allow horizontal scrolling on horizontal and circular sliders
        if _isVertical && self.sliderType == .linear {
            delta = Float(event.deltaY)
        } else if self.userInterfaceLayoutDirection == .rightToLeft {
            delta = Float(event.deltaY + event.deltaX)
        } else {
            delta = Float(event.deltaY - event.deltaX)
        }
        
        // Account for natural scrolling
        if event.isDirectionInvertedFromDevice {
            delta *= -1
        }
        
        let increment = range * delta / 100
        var value = self.floatValue + increment
        
        // Wrap around if slider is circular
        if self.sliderType == .circular {
            let minValue = Float(self.minValue)
            let maxValue = Float(self.maxValue)
            
            if value < minValue {
                value = maxValue - abs(increment)
            } else if value > maxValue {
                value = minValue + abs(increment)
            }
        }
        
        self.floatValue = value
        self.sendAction(self.action, to: self.target)
    }
    
    private var _isVertical: Bool {
        if #available(macOS 10.12, *) {
            return self.isVertical
        } else {
            // isVertical is an NSInteger in versions before 10.12
            return ((self.value(forKey: "isVertical") as? NSInteger) ?? 0) == 1
        }
    }
}
