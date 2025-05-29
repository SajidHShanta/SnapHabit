//
//  CameraPermissionManager.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 21/5/25.
//

import UIKit
import AVFoundation

class CameraPermissionManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private weak var presentingVC: UIViewController?
    private var habitForCheckIn: Habit?
    private var completion: ((UIImage?, Habit?) -> Void)?
    
    init(presentingVC: UIViewController) {
        self.presentingVC = presentingVC
        super.init()
    }
    
    func requestCameraAccessAndPresent(for habit: Habit, completion: @escaping (UIImage?, Habit?) -> Void) {
        self.habitForCheckIn = habit
        self.completion = completion
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentCamera()
                    } else {
                        self.showDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            showDeniedAlert()
        @unknown default:
            showDeniedAlert()
        }
    }
    
    private func presentCamera() {
        guard let vc = presentingVC else { return }
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(title: "Camera Not Available", message: "This device doesn't have a camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            vc.present(alert, animated: true)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        
        vc.present(picker, animated: true)
    }
    
    private func showDeniedAlert() {
        guard let vc = presentingVC else { return }
        
        let alert = UIAlertController(
            title: "Camera Access Denied",
            message: "Please allow camera access in Settings to check in with photos.",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        vc.present(alert, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completion?(nil, nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            let image = info[.originalImage] as? UIImage
            self.completion?(image, self.habitForCheckIn)
        }
      }
  }
