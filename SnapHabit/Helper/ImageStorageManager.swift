//
//  ImageStorageManager.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 19/5/25.
//
import UIKit

struct ImageStorageManager {
    static func save(image: UIImage, withName name: String) {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        let url = getDocumentsDirectory().appendingPathComponent(name)
        try? data.write(to: url)
    }

    static func loadImage(named name: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile: url.path)
    }

    static func deleteImage(named name: String) {
        let url = getDocumentsDirectory().appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("❌ Error deleting image '\(name)': \(error.localizedDescription)")
            }
        }
    }

    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}




//import UIKit
//
//struct ImageStorageManager {
//    static func save(image: UIImage, withName name: String) {
//        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
//        let url = getDocumentsDirectory().appendingPathComponent(name)
//        try? data.write(to: url)
//    }
//
//    static func loadImage(named name: String) -> UIImage? {
//        let url = getDocumentsDirectory().appendingPathComponent(name)
//        return UIImage(contentsOfFile: url.path)
//    }
//
//    static func getDocumentsDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//}
