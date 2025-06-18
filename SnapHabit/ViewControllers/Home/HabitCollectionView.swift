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
        self.register(DoneHabitCollectionViewCell.self, forCellWithReuseIdentifier: "doneCell")
        self.register(NotDoneHabitCollectionViewCell.self, forCellWithReuseIdentifier: "notDoneCell")
        
        self.backgroundColor = .clear
        
//        self.isPagingEnabled = true
        self.showsVerticalScrollIndicator = false
//        self.showsHorizontalScrollIndicator = false
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
        guard let item = items?[indexPath.item] else {
            return self.dequeueReusableCell(withReuseIdentifier: "doneCell", for: indexPath) as! DoneHabitCollectionViewCell
        }
        
        if item.isCheckedInToday {
            let cell = self.dequeueReusableCell(withReuseIdentifier: "doneCell", for: indexPath) as! DoneHabitCollectionViewCell
            cell.populateData(item)
            return cell
        } else {
            let cell = self.dequeueReusableCell(withReuseIdentifier: "notDoneCell", for: indexPath) as! NotDoneHabitCollectionViewCell
            cell.populateData(item)
            cell.onCheckIn = { [weak self] in
                if let self = self,
                   let habit = items?[indexPath.item] {
                    self.onCheckIn?(habit)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = items?[indexPath.item] else {
            return .zero
        }
        
        if item.isCheckedInToday {
            let dummyCell = DoneHabitCollectionViewCell(frame: .init(x: 0, y: 0, width: self.frame.width - 16, height: 1000))
            dummyCell.populateData(item)
            dummyCell.layoutIfNeeded()
            let estimatedSize = dummyCell.systemLayoutSizeFitting(.init(width: self.frame.width - 16, height: 1000))
            return .init(width: self.frame.width, height: estimatedSize.height)

        } else {
            let dummyCell = NotDoneHabitCollectionViewCell(frame: .init(x: 0, y: 0, width: self.frame.width - 16, height: 1000))
            dummyCell.populateData(item)
            dummyCell.layoutIfNeeded()
            let estimatedSize = dummyCell.systemLayoutSizeFitting(.init(width: self.frame.width - 16, height: 1000))
            return .init(width: self.frame.width, height: estimatedSize.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = items?[indexPath.item] {
            onCellTap?(item)
        }
    }
}
