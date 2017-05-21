//
//  UIColor+TLStory.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

public extension UIColor {
    public convenience init(colorHex: UInt32, alpha: CGFloat = 1.0) {
        let red     = CGFloat((colorHex & 0xFF0000) >> 16) / 255.0
        let green   = CGFloat((colorHex & 0x00FF00) >> 8 ) / 255.0
        let blue    = CGFloat((colorHex & 0x0000FF)      ) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
