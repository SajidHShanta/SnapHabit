//
//  UIView+Extension.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 18/6/25.
//

import UIKit

extension UIView {
    public func removeAllSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
}
