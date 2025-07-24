//
//  UserDefaultsManager.swift
//  Dice
//
//  Created by Christos Anastasiades on 6/4/25.
//

import Foundation

/// Singleton for managing user preferences (dice count, sound, always-on-screen) using UserDefaults.
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private enum Keys {
        static let diceCount = "diceCount"
        static let muteSound = "muteSound"
        static let alwaysOnScreen = "alwaysOnScreen"
    }
    
    private init() {}
    
    /// Number of dice to roll (1–6). Defaults to 2 if not set.
    var diceCount: Int {
        get {
            let savedCount = UserDefaults.standard.integer(forKey: Keys.diceCount)
            return savedCount > 0 ? savedCount : 2 // Default to 2 dice if not set
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.diceCount)
        }
    }

    /// Whether rolling sound is muted. Defaults to false.
    var muteSound: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.muteSound)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.muteSound)
        }
    }

    /// Whether always-on-screen mode is enabled. Defaults to false.
    var alwaysOnScreen: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.alwaysOnScreen)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.alwaysOnScreen)
        }
    }
} 