//
//  HabitCollectionViewCell.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 18/6/25.
//

import UIKit
import LBTATools

class DoneHabitCollectionViewCell: UICollectionViewCell {
    
    var container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.lightBackground.cgColor
        return view
    }()
    
    let habitNameLabel = UILabel(text: "", font: .roundedSystemFont(ofSize: 18, weight: .bold), textColor: .text, textAlignment: .left, numberOfLines: 0)
    
    let streakValueLabel = UILabel(text: "", font: .roundedSystemFont(ofSize: 14, weight: .semibold), textColor: .accent, textAlignment: .left, numberOfLines: 1)
    let statusLabel = UILabel(text: "", font: .roundedSystemFont(ofSize: 14, weight: .semibold), textColor: .textLight, textAlignment: .left, numberOfLines: 1)
    
    let imageContainer: UIView = {
        let view = UIView(backgroundColor: .accent)
        view.layer.cornerRadius = 10
        return view
    }()
    
    let todaysImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "logo-transparent")
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 12.5
        imgView.clipsToBounds = true
        return imgView
    }()
    
    let todayLabel: UILabel = {
        let label =  UILabel(text: "Today", font: .roundedSystemFont(ofSize: 14, weight: .semibold), textColor: .white, textAlignment: .center, numberOfLines: 1)
        return label
    }()
    
    let todayLabelContainer: UIView = {
        let view = UIView(backgroundColor: .black.withAlphaComponent(0.8))
        view.layer.cornerRadius = 10
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
                            
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(container)
        container.fillSuperview()
        
//        imageContainer.addSubview(todaysImageView)
//        todaysImageView.fillSuperview()
         
        todayLabelContainer.stack(
            todayLabel
        ).padLeft(16).padRight(16)
        
        todaysImageView.stack(
            UIView(),
            imageContainer.hstack(
                UIView(),
                todayLabelContainer.withHeight(25)
            )
        ).withMargins(.allSides(16))
        
        container.stack(
            container.stack(
                habitNameLabel,
                container.hstack(
                    streakValueLabel,
                    statusLabel,
                    UIView(),
                    spacing: 16
                ),
                spacing: 6
            ),
            todaysImageView.withHeight(100),
            spacing: 16
        ).withMargins(.allSides(16))
    }
    
    func populateData(_ habit: Habit) {
        habitNameLabel.text = habit.title
        streakValueLabel.text = "\(habit.streak) day streak"
        statusLabel.text = habit.isCheckedInToday ? "Done today" : "Not done yet"
        statusLabel.textColor = habit.isCheckedInToday ? .greenDeep : .textLight
        
        if let imgName = habit.entries.last?.imageName {
            todaysImageView.image = ImageStorageManager.loadImage(named: imgName)
        }
    }
    
}



class NotDoneHabitCollectionViewCell: UICollectionViewCell {
    
    var container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.lightBackground.cgColor
        return view
    }()
    
    let habitNameLabel = UILabel(text: "", font: .roundedSystemFont(ofSize: 18, weight: .bold), textColor: .text, textAlignment: .left, numberOfLines: 0)
    
    let streakValueLabel = UILabel(text: "", font: .roundedSystemFont(ofSize: 14, weight: .semibold), textColor: .accent, textAlignment: .left, numberOfLines: 1)
    let statusLabel = UILabel(text: "", font: .roundedSystemFont(ofSize: 14, weight: .semibold), textColor: .textLight, textAlignment: .left, numberOfLines: 1)
    
    let imageContainer: UIView = {
        let view = UIView(backgroundColor: .lightBackground)
        view.layer.cornerRadius = 10
        return view
    }()
    
    let addTodaysPhotoBtn: UIView = {
        let view = UIView(backgroundColor: .accent)
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true
        return view
    }()
    let addTodaysPhotoIcon: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName: "camera.fill"))
        imgView.tintColor = .background
        return imgView
    }()
    let addTodaysPhotoLabel = UILabel(text: "Add Today's Photo", font: .roundedSystemFont(ofSize: 14, weight: .semibold), textColor: .background, textAlignment: .left, numberOfLines: 1)
    
//    lazy var checkInButton: UIButton = {
//        let btn = UIButton(type: .system)
//        
//        // Setup with system image configuration for resizing
//        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
//        let uncheckedImage = UIImage(systemName: "square", withConfiguration: symbolConfig)
//        let checkedImage = UIImage(systemName: "checkmark.square.fill", withConfiguration: symbolConfig)
//        
//        // Default image - can be changed in populateData
//        btn.setImage(uncheckedImage, for: .normal)
//        btn.imageView?.contentMode = .scaleAspectFit
////        btn.tintColor = .white
////        btn.backgroundColor = .systemGreen
////        btn.layer.cornerRadius = 20 // half of width/height for circular button
//        btn.clipsToBounds = true
//        
//        btn.withSize(.init(width: 40, height: 40))
//        
//        return btn
//    }()
    
    var onCheckIn: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        checkInButton.addTarget(self, action: #selector(handleCheckIn), for: .touchUpInside)
        addTodaysPhotoBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCheckIn)))
                    
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(container)
        container.fillSuperview()
        
        addTodaysPhotoBtn.hstack(
            addTodaysPhotoIcon.withWidth(20),
            addTodaysPhotoLabel,
            spacing: 6,
            alignment: .center
        ).padLeft(16).padRight(16)
        
        imageContainer.stack(
            imageContainer.hstack(
                addTodaysPhotoBtn.withHeight(40),//.withSize(.init(width: self.frame.width-96, height: 40)),
                alignment: .center
            ),
            alignment: .center
        )
        
        container.stack(
            container.stack(
                habitNameLabel,
                container.hstack(
                    streakValueLabel,
                    statusLabel,
                    UIView(),
                    spacing: 16
                ),
                spacing: 6
            ),
            imageContainer.withHeight(100),
            spacing: 16
        ).withMargins(.allSides(16))
    }
    
    func populateData(_ habit: Habit) {
        habitNameLabel.text = habit.title
        streakValueLabel.text = "\(habit.streak) day streak"
        statusLabel.text = habit.isCheckedInToday ? "Done today" : "Not done yet"
        statusLabel.textColor = habit.isCheckedInToday ? .greenDeep : .textLight
        
//        addTodaysPhotoBtn.isUserInteractionEnabled = !habit.isCheckedInToday
//        addTodaysPhotoBtn.isHidden = habit.isCheckedInToday
//
//        if habit.isCheckedInToday {
//            if let imgName = habit.entries.last?.imageName {
//                addTodaysPhotoIcon.image = UIImage(named: imgName)
//            }
//        }
//        if let imgName = habit.entries.first?.imageName, habit.isCheckedInToday {
//            let imgView = UIImageView(image: UIImage(named: imgName))
//            imgView.contentMode = .scaleAspectFit
//            imageContainer.addSubview(imgView)
//            imgView.fillSuperview()
//        } else {
////            imageContainer.stack(
////                imageContainer.hstack(
////                    addTodaysPhotoBtn.withHeight(50),
////                    alignment: .center
////                ),
////                alignment: .center
////            )
//
//            imageContainer.addSubview(addTodaysPhotoBtn)
//            addTodaysPhotoBtn.centerInSuperview(size: .init(width: addTodaysPhotoBtn.frame.width-64, height: 50))
//        }
//        imageContainer.addSubview(addTodaysPhotoBtn)
//        addTodaysPhotoBtn.centerInSuperview(size: .init(width: addTodaysPhotoBtn.frame.width-64, height: 50))
        
        // Change button image based on check-in status
//        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
//        let imageName = item.isCheckedInToday ? "checkmark.square.fill" : "square"
//        let image = UIImage(systemName: imageName, withConfiguration: symbolConfig)
//        checkInButton.setImage(image, for: .normal)
    }
    
    @objc private func handleCheckIn() {
        onCheckIn?()
    }
}
