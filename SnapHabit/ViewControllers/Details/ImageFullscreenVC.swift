//
//  ImageFullscreenVC.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 21/5/25.
//

import UIKit
import LBTATools

class ImageFullscreenVC: UIViewController {
    
    let container = UIView()
    
    let titleLabel = UILabel(font: .boldSystemFont(ofSize: 18), textColor: .white)
    let dateLabel = UILabel(font: .boldSystemFont(ofSize: 12), textColor: .white)

    private let image: UIImage
    
    private lazy var imageView = UIImageView(image: image, contentMode: .scaleAspectFit)
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    init(image: UIImage, habitName: String, dateString: String) {
        self.image = image
        self.titleLabel.text = habitName
        self.dateLabel.text = dateString
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide()
        
        let header = UIView()
        titleLabel.numberOfLines = 1
        
        header.hstack(
            container.stack(
                titleLabel.withHeight(30),
                dateLabel.withHeight(20),
                spacing: 1,
                distribution: .fill
            ),
            UIView(),
            closeButton,
            spacing: 2
//            distribution: .fillProportionally
        ).withMargins(.allSides(16))
        
        container.stack(
            header,
            imageView
        ).padBottom(16)
        
        
        // Add down swipe gesture to dismiss
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc private func handleClose() {
        dismiss(animated: true)
    }
    
    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        if translation.y > 100 {
            dismiss(animated: true)
        } else if gesture.state == .changed {
            let alpha = max(0.3, 1 - (translation.y / 300))
            view.alpha = alpha
        } else if gesture.state == .ended || gesture.state == .cancelled {
            UIView.animate(withDuration: 0.2) {
                self.view.alpha = 1
            }
        }
    }
}
