import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private enum Keys {
        static let diceCount = "diceCount"
        static let muteSound = "muteSound"
        static let alwaysOnScreen = "alwaysOnScreen"
    }
    
    private init() {}
    
    var diceCount: Int {
        get {
            let savedCount = UserDefaults.standard.integer(forKey: Keys.diceCount)
            return savedCount > 0 ? savedCount : 2 // Default to 2 dice if not set
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.diceCount)
        }
    }

    var muteSound: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.muteSound)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.muteSound)
        }
    }

    var alwaysOnScreen: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.alwaysOnScreen)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.alwaysOnScreen)
        }
    }
} 