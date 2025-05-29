//
//  BaseVC.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 21/5/25.
//

import UIKit

class BaseVC: UIViewController, UITextFieldDelegate {
    
    let maxHabitTitleLength = 30
    
    // Limit characters in a UIAlertController text field
    func enforceMaxLengthForAlertTextField(_ textField: UITextField) {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if let text = textField.text, text.count > self.maxHabitTitleLength {
                textField.text = String(text.prefix(self.maxHabitTitleLength))
            }
        }
    }
    
    // Generic Alert with optional closure
    func showSimpleAlert(title: String, message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            onDismiss?()
        })
        present(alert, animated: true)
    }
    
    func showError(_ message: String) {
        let errorAlert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(errorAlert, animated: true)
    }
}
