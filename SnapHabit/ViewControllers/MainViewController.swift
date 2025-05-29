//
//  MainViewController.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 19/5/25.
//

import UIKit

class MainViewController: UITabBarController {
    
    let tabbarView = UIView()
    var buttons: [UIButton] = []
    
    let tabbarItemBackgroundView = UIView()
    var centerConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        tabBar.isHidden = true // Hide default tab bar
        generateControllers()
        setView()
    }
    
    private func setView() {
        // Add custom tab bar view
        view.addSubview(tabbarView)
        tabbarView.backgroundColor = .quaternarySystemFill
        tabbarView.translatesAutoresizingMaskIntoConstraints = false
        tabbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        tabbarView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60).isActive = true
        tabbarView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        tabbarView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tabbarView.layer.cornerRadius = 30
        tabbarView.clipsToBounds = true

        // Add highlight background view
        tabbarView.addSubview(tabbarItemBackgroundView)
        tabbarItemBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        tabbarItemBackgroundView.widthAnchor.constraint(equalTo: tabbarView.widthAnchor, multiplier: 1 / CGFloat(buttons.count), constant: -10).isActive = true
        tabbarItemBackgroundView.heightAnchor.constraint(equalTo: tabbarView.heightAnchor, constant: -10).isActive = true
        tabbarItemBackgroundView.centerYAnchor.constraint(equalTo: tabbarView.centerYAnchor).isActive = true
        tabbarItemBackgroundView.layer.cornerRadius = 25
        tabbarItemBackgroundView.backgroundColor = .orange
        tabbarItemBackgroundView.clipsToBounds = true

        // Add buttons
        for x in 0..<buttons.count {
            let button = buttons[x]
            button.tag = x
            tabbarView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.centerYAnchor.constraint(equalTo: tabbarView.centerYAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: tabbarView.widthAnchor, multiplier: 1 / CGFloat(buttons.count)).isActive = true
            button.heightAnchor.constraint(equalTo: tabbarView.heightAnchor).isActive = true
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
            if x == 0 {
                // First button anchor to left
                button.leftAnchor.constraint(equalTo: tabbarView.leftAnchor).isActive = true
                // Initial background constraint
                centerConstraint = tabbarItemBackgroundView.centerXAnchor.constraint(equalTo: button.centerXAnchor)
                centerConstraint?.isActive = true
                button.tintColor = .black // First button selected initially
            } else {
                // Remaining buttons anchored to previous
                button.leftAnchor.constraint(equalTo: buttons[x - 1].rightAnchor).isActive = true
            }
        }
    }
    
    private func generateControllers() {
        let home = generateViewController(image: UIImage(systemName: "house.fill")!, vc: HomeVC())
        let profile = generateViewController(image: UIImage(systemName: "person.fill")!, vc: UIViewController())
        let settings = generateViewController(image: UIImage(systemName: "gearshape.fill")!, vc: UIViewController())
        let bookmarks = generateViewController(image: UIImage(systemName: "bookmark.fill")!, vc: UIViewController())
        viewControllers = [home, profile, settings, bookmarks]
    }
    
    private func generateViewController(image: UIImage, vc: UIViewController) -> UIViewController {
        let button = UIButton()
        button.tintColor = .orange
        let resizedImage = image.resize(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate)
        button.setImage(resizedImage, for: .normal)
        buttons.append(button)
        return vc
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        selectedIndex = sender.tag
        
        // Reset tint for all buttons
        for button in buttons {
            button.tintColor = .orange
        }
        
        // Animate background movement and tint update
        UIView.animate(withDuration: 0.3, animations: {
            self.centerConstraint?.isActive = false
            self.centerConstraint = self.tabbarItemBackgroundView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
            self.centerConstraint?.isActive = true
            self.tabbarView.layoutIfNeeded()
        })
        
        sender.tintColor = .black
    }
}

// MARK: - Image Resize Helper
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
