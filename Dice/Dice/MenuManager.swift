//
//  MenuManager.swift
//  Dice
//
//  Created by Christos Anastasiades on 6/4/25.
//

import UIKit

/// Manages the side menu UI, dimming view, and menu button actions for the Dice app.
class MenuManager: NSObject {
    // MARK: - Properties
    private let sideMenuView: SideMenuView
    private let dimView: UIView
    private var sideMenuLeadingConstraint: NSLayoutConstraint!
    private weak var window: UIWindow?
    
    // MARK: - Constants
    private enum Constants {
        static let menuWidthMultiplier: CGFloat = 0.7
        static let animationDuration: TimeInterval = 0.3
        static let dimViewAlpha: CGFloat = 0.5
    }
    
    /// Initializes the menu manager and sets up the menu UI in the given window.
    init(window: UIWindow) {
        self.window = window
        self.sideMenuView = SideMenuView()
        self.dimView = UIView()
        super.init()
        setupUI()
    }
    
    /// Sets up the dim view and side menu, and adds gesture recognizer for closing the menu.
    private func setupUI() {
        guard let window = window else { return }
        
        // Setup dim view
        dimView.backgroundColor = .black
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(dimView)
        
        // Setup side menu
        sideMenuView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(sideMenuView)
        
        // Setup constraints
        sideMenuLeadingConstraint = sideMenuView.leadingAnchor.constraint(equalTo: window.trailingAnchor)
        
        NSLayoutConstraint.activate([
            // Dim view constraints
            dimView.topAnchor.constraint(equalTo: window.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            
            // Side menu constraints
            sideMenuView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor),
            sideMenuView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            sideMenuView.widthAnchor.constraint(equalTo: window.widthAnchor, multiplier: Constants.menuWidthMultiplier),
            sideMenuLeadingConstraint
        ])
        
        // Set initial position (hidden)
        sideMenuLeadingConstraint.constant = 0
        
        // Add tap gesture to close menu
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideMenu))
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
    
    /// Toggles the menu open/closed with animation.
    func toggleMenu() {
        let isOpening = sideMenuLeadingConstraint.constant == 0
        
        if isOpening {
            // Open menu
            sideMenuLeadingConstraint.constant = -(window?.bounds.width ?? 0) * Constants.menuWidthMultiplier
            // Ensure menu is on top when opening
            window?.bringSubviewToFront(dimView)
            window?.bringSubviewToFront(sideMenuView)
            UIView.animate(withDuration: Constants.animationDuration) {
                self.dimView.alpha = Constants.dimViewAlpha
                self.window?.layoutIfNeeded()
            }
        } else {
            // Close menu
            sideMenuLeadingConstraint.constant = 0
            UIView.animate(withDuration: Constants.animationDuration) {
                self.dimView.alpha = 0
                self.window?.layoutIfNeeded()
            }
        }
    }

    /// Instantly closes the menu without animation.
    func closeMenuImmediately() {
        sideMenuLeadingConstraint.constant = 0
        dimView.alpha = 0
        window?.layoutIfNeeded()
    }
    
    /// Sets the actions for the menu buttons (preferences, feedback).
    func setMenuButtonActions(onGameModeTapped: @escaping () -> Void, onAccountTapped: @escaping () -> Void) {
        sideMenuView.onGameModeTapped = onGameModeTapped
        sideMenuView.onAccountTapped = onAccountTapped
    }
    
    /// Handles tap outside the menu to close it.
    @objc private func handleTapOutsideMenu(_ gesture: UITapGestureRecognizer) {
        guard let window = window else { return }
        let location = gesture.location(in: window)
        if !sideMenuView.frame.contains(location) && sideMenuLeadingConstraint.constant < 0 {
            toggleMenu()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MenuManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let window = window else { return false }
        let location = touch.location(in: window)
        return !sideMenuView.frame.contains(location) && sideMenuLeadingConstraint.constant < 0
    }
} 