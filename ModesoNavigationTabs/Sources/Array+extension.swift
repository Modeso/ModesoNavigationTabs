//
//  Array+extension.swift
//  ModesoNavigationTabs
//
//  Created by Reem Hesham on 8/9/17.
//  Copyright © 2017 Modeso. All rights reserved.
//

import Foundation

extension Array {
    func shiftLeft() -> [Element] {
        return Array(self[1 ..< count] + [self[0]])
    }
    
    func shiftRight() -> [Element] {
        return Array([self[count - 1]] + self[0 ..< count - 1])
    }
    
    mutating func shiftRightInPlace() {
        self = shiftRight()
    }
    
    mutating func shiftLeftInPlace() {
        self = shiftLeft()
    }
}
