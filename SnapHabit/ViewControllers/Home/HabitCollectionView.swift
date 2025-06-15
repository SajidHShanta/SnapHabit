//
//  HabitCollectionView.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 19/5/25.
//

import UIKit
import LBTATools
import RealmSwift

class HabitCollectionView: UICollectionView {
    
    var items: Results<Habit>? {
        didSet {
            self.reloadData()
        }
    }
    
    var onCellTap: ((Habit) -> Void)?
    var onCheckIn: ((Habit) -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        let layout = UICollectionViewFlowLayout()
        //        layout.scrollDirection = .horizontal
        //        layout.minimumLineSpacing = 0
        
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        self.register(HabitCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.isPagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HabitCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HabitCollectionViewCell
        if let item = items?[indexPath.item] {
            cell.populateData(item)
        }
        cell.onCheckIn = { [weak self] in
            if let self = self,
               let habit = items?[indexPath.item] {
                self.onCheckIn?(habit)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: self.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = items?[indexPath.item] {
            onCellTap?(item)
        }
    }
}

class HabitCollectionViewCell: UICollectionViewCell {
    
    var container = UIView(backgroundColor: UIColor(hexString: "#DFE3EB"))
    
    let titleLabel = UILabel(font: .roundedSystemFont(ofSize: 18, weight: .semibold))
    let streakLabel = UILabel(font: .roundedSystemFont(ofSize: 16, weight: .regular))
    let maxStreakLabel = UILabel(font: .roundedSystemFont(ofSize: 16, weight: .regular), textColor: .gray)
    
    //    lazy var checkInButton: UIButton = {
    //        let btn = UIButton()
    //        btn.setImage(UIImage(named: "checkin-tick"), for: .normal)
    //        btn.imageView?.contentMode = .scaleAspectFit
    //        btn.clipsToBounds = true
    //        return btn
    //    }()
    
    lazy var checkInButton: UIButton = {
        let btn = UIButton(type: .system)
        
        // Setup with system image configuration for resizing
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let uncheckedImage = UIImage(systemName: "square", withConfiguration: symbolConfig)
        let checkedImage = UIImage(systemName: "checkmark.square.fill", withConfiguration: symbolConfig)
        
        // Default image - can be changed in populateData
        btn.setImage(uncheckedImage, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
//        btn.tintColor = .white
//        btn.backgroundColor = .systemGreen
//        btn.layer.cornerRadius = 20 // half of width/height for circular button
        btn.clipsToBounds = true
        
        btn.withSize(.init(width: 40, height: 40))
        
        return btn
    }()
    
    var onCheckIn: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        checkInButton.addTarget(self, action: #selector(handleCheckIn), for: .touchUpInside)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(container)
        container.fillSuperview()
        
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 8
        
        titleLabel.numberOfLines = 0
        
        container.stack(
            container.hstack(
                titleLabel,
                container.stack(
                    streakLabel,
                    maxStreakLabel,
                    spacing: 6,
                    distribution: .fillEqually
                    
                ),
                checkInButton,//.withSize(.init(width: 80, height: 80)),
                spacing: 16
            )
        ).withMargins(.allSides(16))
    }
    
    func populateData(_ item: Habit) {
        titleLabel.text = item.title
        streakLabel.text = "🔥 Streak: \(item.streak)"
        maxStreakLabel.text = "🏆 Max: \(item.maxStreak)"
        
        // Change button image based on check-in status
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        let imageName = item.isCheckedInToday ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        checkInButton.setImage(image, for: .normal)
    }
    
    @objc private func handleCheckIn() {
        onCheckIn?()
    }
}
