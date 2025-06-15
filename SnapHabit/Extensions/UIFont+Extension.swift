//
//  UIFont+Extension.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 4/6/25.
//

import UIKit

extension UIFont {
    static func roundedSystemFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let roundedDescriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: roundedDescriptor, size: size)
        } else {
            return systemFont
        }
    }
}
