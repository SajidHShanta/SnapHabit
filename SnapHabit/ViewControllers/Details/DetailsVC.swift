//
//  DetailsVC.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 19/5/25.
//

import UIKit
import LBTATools
import RealmSwift

class DetailsVC: BaseVC {
    
    let container = UIView(backgroundColor: .clear)
    
    let streakContainer: UIView = {
        let view = UIView(backgroundColor: .clear)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.lightBackground.cgColor
        return view
    }()
    
    let imageGridContainer: UIView = {
        let view = UIView(backgroundColor: .clear)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.lightBackground.cgColor
        return view
    }()
    
    let yourStreaksTitleLabel = UILabel(text: "Your Streaks", font: .roundedSystemFont(ofSize: 18, weight: .bold), textColor: .text, textAlignment: .left, numberOfLines: 1)
    let currentStreakTitleLabel  = UILabel(text: "Current Streak", font: .roundedSystemFont(ofSize: 14, weight: .regular), textColor: .textLight, textAlignment: .center, numberOfLines: 1)
    let bestStreakTitleLabel  = UILabel(text: "Best Streak", font: .roundedSystemFont(ofSize: 14, weight: .regular), textColor: .textLight, textAlignment: .center, numberOfLines: 1)

    let currentStreakValueLabel  = UILabel(text: "", font: .roundedSystemFont(ofSize: 48, weight: .bold), textColor: .accent, textAlignment: .center, numberOfLines: 1)
    let bestStreakValueLabel  = UILabel(text: "", font: .roundedSystemFont(ofSize: 48, weight: .bold), textColor: .textLight, textAlignment: .center, numberOfLines: 1)
    
    let currentDayLabel  = UILabel(text: "days", font: .roundedSystemFont(ofSize: 12, weight: .regular), textColor: .textLight, textAlignment: .center, numberOfLines: 1)
    let bestDayLabel  = UILabel(text: "days", font: .roundedSystemFont(ofSize: 12, weight: .regular), textColor: .textLight, textAlignment: .center, numberOfLines: 1)
    
    let streakQuoteLabel = UILabel(text: "Keep up the great work! Every day counts.", font: .roundedSystemFont(ofSize: 14, weight: .regular), textColor: .textLight, textAlignment: .center, numberOfLines: 1)
    
    let imageGridTitle = UILabel(text: "Visual Progress", font: .roundedSystemFont(ofSize: 18, weight: .bold), textColor: .text, textAlignment: .left, numberOfLines: 1)
    let entryGridView = HabitEntryGridView()
    
    let bottomBtnView: UIView = {
        let view = UIView(backgroundColor: .accent)
        view.layer.cornerRadius = 10
        return view
    }()
    let bottomBtnIcon: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName: "camera.fill"))
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = .background
        return imgView
    }()
    let bottomBtnLabel = UILabel(text: "", font: .roundedSystemFont(ofSize: 14, weight: .semibold), textColor: .background, textAlignment: .left, numberOfLines: 1)
    
    var cameraManager: CameraPermissionManager!

    //    private let realm = try! Realm()
    private lazy var realm = try! Realm()
    
    private var habit: Habit {
        didSet {
            updateValues()
        }
    }
    
    init(habit: Habit) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        cameraManager = CameraPermissionManager(presentingVC: self)
        
        bottomBtnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkInTapped)))

        updateValues()
        setupNav()
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .background
        view.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide()
        
        streakContainer.stack(
            yourStreaksTitleLabel,
            streakContainer.hstack(
                streakContainer.stack(
                    currentStreakTitleLabel,
                    currentStreakValueLabel,
                    currentDayLabel,
                    spacing: 3
                ),
                streakContainer.stack(
                    bestStreakTitleLabel,
                    bestStreakValueLabel,
                    bestDayLabel,
                    spacing: 3
                ),
                spacing: 16,
                distribution: .fillEqually
            ),
            UIView(backgroundColor: .lightBackground).withHeight(2),
            streakQuoteLabel,
            spacing: 16
        ).withMargins(.allSides(16))
        
        setupGridView()
        imageGridContainer.stack(
            imageGridTitle,
            entryGridView,
            spacing: 16
        ).withMargins(.allSides(16))
        
        bottomBtnView.stack(
            bottomBtnView.hstack(
                bottomBtnIcon.withWidth(20),
                bottomBtnLabel,
                spacing: 6,
                alignment: .center
            ),
            alignment: .center
        )
        
        container.stack(
            streakContainer,
            imageGridContainer,
            bottomBtnView.withHeight(50),
            spacing: 16
        ).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    fileprivate func updateValues() {
        self.title = habit.title
        entryGridView.items = habit.entries.sorted(by: { $0.date > $1.date })
        currentStreakValueLabel.text = "\(habit.streak)"
        bestStreakValueLabel.text = "\(habit.maxStreak)"
        currentDayLabel.text = habit.streak == 1 ? "day" : "days"
        bestDayLabel.text = habit.streak == 1 ? "day" : "days"
        
        imageGridContainer.isHidden = habit.entries.isEmpty
        
        if habit.isCheckedInToday {
            bottomBtnView.backgroundColor = .greenLight
            bottomBtnLabel.textColor = .greenDeep
            bottomBtnLabel.text = "Completed Today!"
            bottomBtnIcon.image = UIImage(systemName: "checkmark.circle.fill")
            bottomBtnIcon.tintColor = .greenDeep
            bottomBtnView.isUserInteractionEnabled = false
        } else {
            bottomBtnView.backgroundColor = .accent
            bottomBtnLabel.textColor = .background
            bottomBtnLabel.text = "Upload Today's Photo"
            bottomBtnIcon.image = UIImage(systemName: "camera.fill")
            bottomBtnIcon.tintColor = .background
            bottomBtnView.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func setupNav() {
        self.navigationController?.isNavigationBarHidden = false
        title = habit.title
        navigationItem.backButtonTitle = ""
        
        let appearance = UINavigationBarAppearance()
          appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.text]
          appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.text]
          
          navigationController?.navigationBar.standardAppearance = appearance
          navigationController?.navigationBar.compactAppearance = appearance
          navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let edit = makeNavButton(image: UIImage(systemName: "square.and.pencil")!, action: #selector(handleEdit))
        let delete = makeNavButton(image: UIImage(systemName: "trash")!, action: #selector(handleDelete), tintColor: .red)

        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: delete), UIBarButtonItem(customView: edit)] // right to left
    }
    
    func makeNavButton(image: UIImage, action: Selector, tintColor: UIColor = .accent) -> UIView {
        let imageView = UIImageView(image: image)
        imageView.tintColor = tintColor
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
//        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: action)
        imageView.addGestureRecognizer(tap)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.frame = container.bounds
        container.addSubview(imageView)
        
        return container
    }

    fileprivate func setupGridView() {
        entryGridView.items = habit.entries.sorted(by: { $0.date > $1.date })
        entryGridView.onCellTap = { [weak self] entry in
            guard let self = self else { return }
            if let imageName = entry.imageName,
               let image = ImageStorageManager.loadImage(named: imageName) {
                let vc = ImageFullscreenVC(image: image, habitName: habit.title, dateString: entry.date.formatted(date: .abbreviated, time: .omitted))
                self.present(vc, animated: true)
            }
        }
    }
    
    @objc func handleEdit() {
        let alert = UIAlertController(title: "Edit Habit Name", message: "Enter a new name for your habit", preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            textField.text = self?.habit.title
            textField.placeholder = "Habit name"
            self?.enforceMaxLengthForAlertTextField(textField)
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newTitle = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newTitle.isEmpty,
                  newTitle != self.habit.title else {
                return
            }
            
            if self.realm.object(ofType: Habit.self, forPrimaryKey: newTitle) != nil {
                self.showSimpleAlert(title: "Name Taken", message: "Another habit already uses this name.")
                return
            }
            
            self.editHabitName(self.habit, to: newTitle, in: self.realm)
            self.showSimpleAlert(title: "Updated", message: "Habit name updated to \"\(newTitle)\".")
            
            // refresh related UI
            //            self.title = self.habit.title
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc func handleDelete() {
        let alert = UIAlertController(
            title: "Delete Habit",
            message: "Are you sure you want to delete \"\(habit.title)\"?\nThis will remove all its check-ins too.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            let tempTitle = self.habit.title
            self.deleteHabit(self.habit, from: self.realm)
            self.showSimpleAlert(title: "Deleted", message: "Habit \"\(tempTitle)\" has been deleted.") {
                //pop view or reload list here
                self.navigationController?.popViewController(animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    
    func editHabitName(_ habit: Habit, to newTitle: String, in realm: Realm) {
        do {
            try realm.write {
                // Create a new habit with the new title
                let updatedHabit = Habit()
                updatedHabit.title = newTitle
                updatedHabit.createdAt = habit.createdAt
                updatedHabit.lastCheckInDate = habit.lastCheckInDate
                updatedHabit.streak = habit.streak
                updatedHabit.maxStreak = habit.maxStreak
                updatedHabit.entries.append(objectsIn: habit.entries)
                
                // Add the new habit before deleting old one
                realm.add(updatedHabit, update: .modified)
                
                realm.delete(habit)
                
                self.habit = updatedHabit
            }
        } catch {
            print("❌ Error editing habit title: \(error.localizedDescription)")
        }
    }
    
    func deleteHabit(_ habit: Habit, from realm: Realm) {
        do {
            try realm.write {
                // Delete stored images for this habit
                for entry in habit.entries {
                    if let imageName = entry.imageName {
                        ImageStorageManager.deleteImage(named: imageName)
                    }
                }
                realm.delete(habit.entries) // Delete all entries first
                realm.delete(habit)         // Then delete the habit itself
                
                //                self.showSimpleAlert(title: "Deleted", message: "Habit has been deleted.") {
                //                    self.navigationController?.popViewController(animated: true)
                //                }
            }
        } catch {
            print("❌ Error deleting habit: \(error.localizedDescription)")
        }
    }
    
    @objc func checkInTapped() {
        if habit.isCheckedInToday {
            showSimpleAlert(title: "Oops!", message: "You’ve already checked in today for \(self.habit.title).")
            return
        }
        
        cameraManager.requestCameraAccessAndPresent(for: habit) { [weak self] image, habit in
            guard let self = self, let habit = habit else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                try? self.realm.write {
                    habit.checkIn(realm: self.realm, withImage: image)
                }
                
                self.habit = habit
                self.showSimpleAlert(
                    title: "Great job!",
                    message: "Successfully checked in for \"\(habit.title)\". Keep the streak going! 💪"
                )
            }
        }
        
        
//        cameraManager.requestCameraAccessAndPresent(for: habit) { [weak self] image, habit in
//            guard let self = self, let habit = habit else { return }
//
//            DispatchQueue.main.async {
//                do {
//                    try self.realm.write {
//                        habit.checkIn(realm: self.realm, withImage: image)
//                    }
//
//                    self.habit = habit
//                    self.showSimpleAlert(
//                        title: "Great job!",
//                        message: "Successfully checked in for \"\(habit.title)\". Keep the streak going! 💪"
//                    )
//                } catch {
//                    print("❌ Realm write error: \(error)")
//                }
//            }
//        }
        
    }
    
}
