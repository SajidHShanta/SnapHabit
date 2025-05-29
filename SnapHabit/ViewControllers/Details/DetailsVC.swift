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
    
    let container = UIView()
    
    let streakLabel = UILabel(font: .systemFont(ofSize: 16))
    let maxStreakLabel = UILabel(font: .systemFont(ofSize: 14), textColor: .gray)
    
    let editButton: UIImageView = {
        let btn = UIImageView(image: UIImage(systemName: "square.and.pencil.circle")!, contentMode: .scaleAspectFit)
        btn.clipsToBounds = true
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    let deleteButton: UIImageView = {
        let btn = UIImageView(image: UIImage(systemName: "trash.circle")!, contentMode: .scaleAspectFit)
        btn.tintColor = .red
        btn.clipsToBounds = true
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    let entryGridView = HabitEntryGridView()
    
    private let realm = try! Realm()

    private var habit: Habit {
        didSet {
            self.title = habit.title
            entryGridView.items = habit.entries.sorted(by: { $0.date > $1.date })
            streakLabel.text = "🔥 Streak: \(habit.streak)"
            maxStreakLabel.text = "🏆 Max: \(habit.maxStreak)"
        }
    }
    
//    var entries: [HabitEntry] {
//        return habit.entries.sorted(by: { $0.date > $1.date })
//    }
    
    
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
        title = habit.title
        
        editButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEdit)))
        deleteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDelete)))
        
        entryGridView.items = habit.entries.sorted(by: { $0.date > $1.date })
        entryGridView.onCellTap = { [weak self] entry in
            guard let self = self else { return }
            if let imageName = entry.imageName,
               let image = ImageStorageManager.loadImage(named: imageName) {
                let vc = ImageFullscreenVC(image: image, habitName: habit.title, dateString: entry.date.formatted(date: .abbreviated, time: .omitted))
                self.present(vc, animated: true)
            }
        }
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide()

        streakLabel.text = "🔥 Streak: \(habit.streak)"
        maxStreakLabel.text = "🏆 Max: \(habit.maxStreak)"
                
//        container.stack(
//            streakLabel,
//            maxStreakLabel,
//            container.hstack(
//                editButton.withSize(.init(width: 100, height: 100)),
//                deleteButton.withSize(.init(width: 50, height: 50)),
//                spacing: 16,
//                distribution: .fillEqually
//            ),
//            UIView(),
//            spacing: 16
//        ).withMargins(.allSides(16))
        
        
        
        container.stack(
            streakLabel,
            maxStreakLabel,
            container.hstack(
                editButton.withSize(.init(width: 50, height: 50)),
                deleteButton.withSize(.init(width: 50, height: 50)),
                spacing: 16,
                distribution: .fillEqually
            ),
            entryGridView,
            spacing: 16
        ).withMargins(.allSides(16))
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

}
