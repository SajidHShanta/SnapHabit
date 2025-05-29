//
//  Habit.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 19/5/25.
//

import RealmSwift

// MARK: - Habit Model
class Habit: Object {
    @Persisted(primaryKey: true) var title: String  // Unique habit title
    
    @Persisted var createdAt: Date = Date()
    @Persisted var lastCheckInDate: Date? = nil
    @Persisted var streak: Int = 0
    @Persisted var maxStreak: Int = 0
    
    // List of daily habit entries (one-to-many)
    @Persisted var entries = List<HabitEntry>()
    
    var isCheckedInToday: Bool {
         guard let lastCheckIn = lastCheckInDate else { return false }
         return Calendar.current.isDateInToday(lastCheckIn)
     }
    
    // MARK: - Check In Logic
    func checkIn(realm: Realm, withImage image: UIImage? = nil) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = lastCheckInDate {
            let lastCheck = calendar.startOfDay(for: lastDate)
            let diff = calendar.dateComponents([.day], from: lastCheck, to: today).day ?? 0

            if diff == 0 { return }           // Already checked in today
            else if diff == 1 { streak += 1 } // Continue streak
            else { streak = 1 }               // Reset streak
        } else {
            streak = 1 // First ever check-in
        }

        if streak > maxStreak {
            maxStreak = streak
        }

        lastCheckInDate = today
        
        // Create new habit entry for today
        let newEntry = HabitEntry()
        newEntry.date = today

        if let image = image {
            let imageName = UUID().uuidString + ".jpg"
            ImageStorageManager.save(image: image, withName: imageName)
            newEntry.imageName = imageName
        }
        entries.append(newEntry)
    }
    
//    private func hasEntryForToday(_ habit: Habit) -> Bool {
//        let today = Calendar.current.startOfDay(for: Date())
//        return habit.entries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
//    }

}

// MARK: - Habit Entry Model
class HabitEntry: Object {
    @Persisted var date: Date = Date()
    @Persisted var imageName: String?  // store only the image file name
}
