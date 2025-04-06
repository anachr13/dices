//
//  AppDelegate.swift
//  Dice
//
//  Created by Christos Anastasiades on 6/4/25.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create window with proper bounds
        let screenBounds = UIScreen.main.bounds
        window = UIWindow(frame: screenBounds)
        window?.backgroundColor = .white
        
        // Create and set root view controller
        let viewController = ViewController()
        window?.rootViewController = viewController
        
        // Make window visible and set it as key window
        window?.makeKeyAndVisible()
        
        // Force layout update
        window?.layoutIfNeeded()
        
        return true
    }
}

