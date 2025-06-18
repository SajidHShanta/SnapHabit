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
        
    private let conatiner = UIView()
    private let upperContainer = UIView()
    private let progressContainer: UIView = {
        let view = UIView(backgroundColor: .lightAccent)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let appNameLabel = UILabel(text: "SnapHabit", font: .roundedSystemFont(ofSize: 24, weight: .black), textColor: .text, textAlignment: .left, numberOfLines: 1)
    private let dateLabel = UILabel(text: Date().formatted(.dateTime.weekday(.wide).day().month(.wide)), font: .roundedSystemFont(ofSize: 14, weight: .regular), textColor: .textLight, textAlignment: .left, numberOfLines: 1)
    private let settingsButton: UIImageView = {
        let btn = UIImageView(image: UIImage(systemName: "person.crop.circle.fill")!, contentMode: .scaleAspectFit)
        btn.isUserInteractionEnabled = true
        btn.tintColor = .darkGray
        btn.backgroundColor = .lightBackground
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    private let progressTitleLabel = UILabel(text: "Today's Progress", font: .roundedSystemFont(ofSize: 18, weight: .bold), textColor: .text, textAlignment: .left, numberOfLines: 1)
    private let progressValueLabel  = UILabel(text: "", font: .roundedSystemFont(ofSize: 14, weight: .semibold), textColor: .accent, textAlignment: .left, numberOfLines: 1)
    private let progressBar: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = .accent
        view.trackTintColor = .white.withAlphaComponent(0.5)
        return view
    }()
    private let progressQuoteLabel  = UILabel(text: "You're building great momentum! Keep it up!", font: .roundedSystemFont(ofSize: 14, weight: .regular), textColor: .textLight, textAlignment: .left, numberOfLines: 1)
    
    private let habitTitleLabel = UILabel(text: "My Habits", font: .roundedSystemFont(ofSize: 18, weight: .bold), textColor: .text, textAlignment: .left, numberOfLines: 1)
    let addButton: UIImageView = {
        let btn = UIImageView(image: UIImage(systemName: "plus.square.fill")!, contentMode: .scaleAspectFit)
        btn.clipsToBounds = true
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    private let habitCollectionView = HabitCollectionView()
    
//    private let realm = try! Realm()
    private lazy var realm = try! Realm()

    private var notificationToken: NotificationToken?
    
    var cameraManager: CameraPermissionManager!
    
    var habits: Results<Habit>? {
        didSet {
            habitCollectionView.items = habits
            updateProgress()
        }
    }
    
    var doneHabitCount: Int = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        title = "SnapHabit"
        self.navigationController?.isNavigationBarHidden = true
        
        cameraManager = CameraPermissionManager(presentingVC: self)
        
        addButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addHabitTapped)))
                
        habitCollectionView.onCellTap = { [weak self] habit in
            guard let self = self else { return }
            habitCardTapped(habit)
        }
        habitCollectionView.onCheckIn = { [weak self] habit in
            guard let self = self else { return }
            checkInTapped(habit)
        }
                
        setupViews()
        updateProgress()
        
        DispatchQueue.main.async {
            self.loadHabits()
        }
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                let warmup = realm.objects(Habit.self).sorted(byKeyPath: "createdAt", ascending: true)
//                _ = warmup.first // Force lazy load, schema access
//            }
//
//            DispatchQueue.main.async {
//                self.loadHabits()
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .background
        view.addSubview(conatiner)
        conatiner.fillSuperviewSafeAreaLayoutGuide()
        
        upperContainer.hstack(
            upperContainer.stack(
                appNameLabel,
                dateLabel,
                spacing: 6
            ),
            UIView(),
            settingsButton.withSize(.init(width: 50, height: 50)),
            spacing: 6
        )
        
        progressContainer.stack(
            progressContainer.hstack(
                progressTitleLabel,
                UIView(),
                progressValueLabel,
                spacing: 6
            ),
            UIView().withHeight(3),
            progressBar.withHeight(10),
            progressQuoteLabel,
            spacing: 10
        ).withMargins(.allSides(16))
        
        conatiner.stack(
            upperContainer,
            progressContainer,
            conatiner.hstack(
                habitTitleLabel,
                UIView(),
                addButton.withSize(.init(width: 35, height: 35))
            ),
            habitCollectionView,
            spacing: 16
        ).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    fileprivate func updateProgress() {
        if let total = habits?.count,
           let doneToday = habits?.count(where: {$0.isCheckedInToday}) {
            progressValueLabel.text = "\(doneToday)/\(total) completed"
            
            progressBar.progress = (Float(doneToday) / Float(total))
        } else {
            progressValueLabel.text = ""
        }
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

        DispatchQueue.main.async {
            self.observeHabits()
        }
    }
    
    fileprivate func observeHabits() {
        guard let habits = habits else { return }
        
        notificationToken = habits.observe { [weak self] changes in
            DispatchQueue.main.async {
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
        
//        cameraManager.requestCameraAccessAndPresent(for: habit) { [weak self] image, habit in
//            guard let self = self, let habit = habit else { return }
//            
//            try? self.realm.write {
//                habit.checkIn(realm: self.realm, withImage: image)
//            }
//            
//            // Reload the specific habit cell to reflect check-in
//            if let index = habits?.firstIndex(of: habit) {
//                habitCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
//            }
//            
//            self.showSimpleAlert(
//                title: "Great job!",
//                message: "Successfully checked in for \"\(habit.title)\". Keep the streak going! 💪"
//            )
//        }
        
        cameraManager.requestCameraAccessAndPresent(for: habit) { [weak self] image, habit in
            guard let self = self, let habit = habit else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                try? self.realm.write {
                    habit.checkIn(realm: self.realm, withImage: image)
                }
                
                DispatchQueue.main.async {
                    if let index = self.habits?.firstIndex(of: habit) {
                        self.habitCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                    self.showSimpleAlert(
                        title: "Great job!",
                        message: "Successfully checked in for \"\(habit.title)\". Keep the streak going! 💪"
                    )
                }
            }
        }
        
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}
