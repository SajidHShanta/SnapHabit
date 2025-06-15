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
    private let upperView = UIView()
    
    private let cameraImgView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "camera-solid")?.withRenderingMode(.alwaysTemplate)
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .accent
        return imageView
    }()
    
    private let circularProgressView = CircularProgressView()

    private let belowLabel: UILabel = {
        let label = UILabel()
        label.text = "3 of 4 tasks done today."
        label.font = .roundedSystemFont(ofSize: 18, weight: .regular)
        label.textColor = .background
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel = UILabel(text: "Habits", font: .roundedSystemFont(ofSize: 22, weight: .bold), textColor: .black, textAlignment: .left, numberOfLines: 1)
    
    let addButton: UIImageView = {
        let btn = UIImageView(image: UIImage(systemName: "plus.square.fill")!, contentMode: .scaleAspectFit)
        btn.clipsToBounds = true
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
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
        
        title = "SnapHabit"
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
                
//        setupNav()
        setupViews()
        loadHabits()
        
        circularProgressView.setProgress(0.75)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
//    fileprivate func setupNav() {
//        title = "SnapHabit"
//                
//        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
//        let plusImage = UIImage(systemName: "plus.square.fill", withConfiguration: config)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: plusImage,
//            style: .plain,
//            target: self,
//            action: #selector(addHabitTapped)
//        )
//        navigationItem.rightBarButtonItem?.tintColor = .systemGreen
//        
//    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .background
        view.addSubview(conatiner)
        conatiner.fillSuperviewSafeAreaLayoutGuide()
        
        upperView.addSubview(cameraImgView)
        cameraImgView.anchor(
            top: upperView.topAnchor,
            leading: upperView.leadingAnchor,
            bottom: upperView.bottomAnchor,
            trailing: upperView.trailingAnchor
        )
        // Set aspect ratio constraint (height = width * aspect ratio)
        if let img = cameraImgView.image {
            let ratio = img.size.height / img.size.width
            cameraImgView.heightAnchor.constraint(equalTo: cameraImgView.widthAnchor, multiplier: ratio).isActive = true
        }
        
        
        // Add circular view and label inside cameraImgView
        cameraImgView.addSubview(circularProgressView)
        cameraImgView.addSubview(belowLabel)
        
        let h = view.frame.width/3
        circularProgressView.constrainWidth(h)
        circularProgressView.constrainHeight(h)
        circularProgressView.backgroundColor = .accent
        circularProgressView.layer.cornerRadius = h/2
        // Center the circle in the image view
        circularProgressView.centerInSuperview()

        // Anchor the label below the circle
        belowLabel.anchor(top: circularProgressView.bottomAnchor, leading: cameraImgView.leadingAnchor, bottom: cameraImgView.bottomAnchor, trailing: cameraImgView.trailingAnchor)
                
        conatiner.stack(
            upperView,
            conatiner.hstack(
                titleLabel,
                UIView(),
                addButton.withSize(.init(width: 35, height: 35))
            ),
            habitCollectionView,
            spacing: 16
        ).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
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
