//
//  HabitEntryGridView.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 21/5/25.
//

import UIKit
import LBTATools
import RealmSwift

class HabitEntryGridView: UICollectionView {
    
    var items: [HabitEntry]? {
        didSet {
            self.reloadData()
        }
    }
    
    var onCellTap: ((HabitEntry) -> Void)?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        delegate = self
        dataSource = self
        register(HabitEntryGridCell.self, forCellWithReuseIdentifier: "entryCell")
        
        backgroundColor = .clear
        isScrollEnabled = true
        contentInset = .zero
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HabitEntryGridView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "entryCell", for: indexPath) as! HabitEntryGridCell
        if let entry = items?[indexPath.item] {
            cell.populate(entry)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let entry = items?[indexPath.item] {
            onCellTap?(entry)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 8
        let totalSpacing = (columns - 1) * spacing
        let cellWidth = (frame.width - totalSpacing) / columns
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

class HabitEntryGridCell: UICollectionViewCell {
    
    let imageView = UIImageView(image: nil, contentMode: .scaleAspectFill)
    let dateLabel: UILabel = {
        let label =  UILabel(text: "Today", font: .roundedSystemFont(ofSize: 12, weight: .semibold), textColor: .white, textAlignment: .center, numberOfLines: 0)
        label.sizeToFit()
        return label
    }()
    let dateContainer: UIView = {
        let view = UIView(backgroundColor: .black.withAlphaComponent(0.4))
        view.layer.cornerRadius = 10
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 8
        
        self.addSubview(imageView)
        imageView.fillSuperview()
        
        dateContainer.stack(
            dateLabel
        ).padLeft(16).padRight(16)
        
        imageView.stack(
            imageView.hstack(
                dateContainer.withHeight(25)
            )
        ).withMargins(.allSides(6))
        
        backgroundColor = .accent
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(_ entry: HabitEntry) {
        if let imageName = entry.imageName,
           let image = ImageStorageManager.loadImage(named: imageName) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        dateLabel.text = formatter.string(from: entry.date)
    }
}
