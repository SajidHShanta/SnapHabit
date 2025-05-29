//
//  HomeVC.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 19/5/25.
//

import UIKit
import LBTATools
import RealmSwift

class HomeVC: BaseVC {
    
    let tabbarView = UIView()
    
    private let conatiner = UIView(backgroundColor: .red)
    
    private let habitCollectionView = HabitCollectionView()
    
    private let realm = try! Realm()
    private var notificationToken: NotificationToken?
    
    var cameraManager: CameraPermissionManager!
    
    var habits: Results<Habit>? {
        didSet {
            habitCollectionView.items = habits
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        cameraManager = CameraPermissionManager(presentingVC: self)
                
        habitCollectionView.onCellTap = { [weak self] habit in
            guard let self = self else { return }
            habitCardTapped(habit)
        }
        habitCollectionView.onCheckIn = { [weak self] habit in
            guard let self = self else { return }
            checkInTapped(habit)
        }
                
        setupNav()
        setupViews()
        loadHabits()
    }
    
    fileprivate func setupNav() {
        title = "SnapHabit"
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square.fill")!, style: .plain, target: self, action: #selector(addHabitTapped))
        
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let plusImage = UIImage(systemName: "plus.square.fill", withConfiguration: config)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: plusImage,
            style: .plain,
            target: self,
            action: #selector(addHabitTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen
        
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        view.addSubview(conatiner)
        conatiner.fillSuperviewSafeAreaLayoutGuide()
                
        conatiner.stack(
            habitCollectionView
        )
    }
    
    @objc func addHabitTapped() {
        let alert = UIAlertController(title: "New Habit", message: "Enter habit title", preferredStyle: .alert)

        alert.addTextField { [weak self] textField in
            textField.placeholder = "Habit title"
            self?.enforceMaxLengthForAlertTextField(textField)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !title.isEmpty else { return }

            if self.realm.object(ofType: Habit.self, forPrimaryKey: title) != nil {
                self.showError("Habit with this title already exists!")
                return
            }

            let newHabit = Habit()
            newHabit.title = title
            newHabit.createdAt = Date()

            try? self.realm.write {
                self.realm.add(newHabit)
            }
        })

        present(alert, animated: true)
    }

    
    fileprivate func loadHabits() {
        habits = realm.objects(Habit.self).sorted(byKeyPath: "createdAt", ascending: true)
        observeHabits()
    }
    
    fileprivate func observeHabits() {
        guard let habits = habits else { return }
        
        notificationToken = habits.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial:
                self.habitCollectionView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.habitCollectionView.performBatchUpdates {
                    self.habitCollectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: 0) })
                    self.habitCollectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: 0) })
                    self.habitCollectionView.reloadItems(at: modifications.map { IndexPath(item: $0, section: 0) })
                }
            case .error(let error):
                print("Realm error: \(error)")
            }
        }
        
    }
    
    private func habitCardTapped(_ habit: Habit) {
        print("selected habit: \(habit.title)")
        self.navigationController?.pushViewController(DetailsVC(habit: habit), animated: true)
    }
    
    func checkInTapped(_ habit: Habit) {
        if habit.isCheckedInToday {
            showSimpleAlert(title: "Oops!", message: "You’ve already checked in today for \(habit.title).") {
                self.navigationController?.pushViewController(DetailsVC(habit: habit), animated: true)
            }
            return
        }
        
        cameraManager.requestCameraAccessAndPresent(for: habit) { [weak self] image, habit in
            guard let self = self, let habit = habit else { return }
            
            try? self.realm.write {
                habit.checkIn(realm: self.realm, withImage: image)
            }
            
            // Reload the specific habit cell to reflect check-in
            if let index = habits?.firstIndex(of: habit) {
                habitCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
            
            self.showSimpleAlert(
                title: "Great job!",
                message: "Successfully checked in for \"\(habit.title)\". Keep the streak going! 💪"
            )
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}
