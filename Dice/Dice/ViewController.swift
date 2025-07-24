//
//  ViewController.swift
//  Dice
//  
//  Created by Christos Anastasiades on 6/4/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    private var audioPlayer: AVAudioPlayer?
    private var isRolling = false
    
    // Menu properties
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.7) // Debug: make button visible
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let rollButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Roll", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let diceGridContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var diceViews: [DiceView] = []
    private var menuManager: MenuManager!
    private var appWindow: UIWindow? // Store reference to window
    private var lastDiceCount: Int = 1 // Track last dice count, now min 1
    private var currentOrientationIsPortrait: Bool = true
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var portraitCenterYConstraint: NSLayoutConstraint?
    private var portraitTopConstraint: NSLayoutConstraint?
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudio()
        setupDice()
        // Remove setupMenu() from here
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMenu() // Call here instead
        closeMenuIfOpen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let diceCount = min(max(UserDefaultsManager.shared.diceCount, 1), 6)
        if diceCount != lastDiceCount {
            setupDice()
            lastDiceCount = diceCount
        }
        UIApplication.shared.isIdleTimerDisabled = UserDefaultsManager.shared.alwaysOnScreen
        currentOrientationIsPortrait = view.bounds.height >= view.bounds.width
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let isPortrait = view.bounds.height >= view.bounds.width
        if isPortrait != currentOrientationIsPortrait {
            currentOrientationIsPortrait = isPortrait
            setupDice()
        }
        updateOrientationConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore idle timer to default when leaving main screen
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        // Add main stack view (only for dice)
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(diceGridContainer)
        // Add roll button separately, anchored to bottom
        view.addSubview(rollButton)
        rollButton.addTarget(self, action: #selector(rollButtonTapped), for: .touchUpInside)

        // Portrait constraints (centered or top)
        portraitCenterYConstraint = mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        portraitTopConstraint = mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        portraitConstraints = [
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // vertical constraint will be handled dynamically
            mainStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            rollButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rollButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            rollButton.widthAnchor.constraint(equalToConstant: 200),
            rollButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        // Landscape constraints (mainStackView at top, button at bottom)
        landscapeConstraints = [
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            rollButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rollButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            rollButton.widthAnchor.constraint(equalToConstant: 200),
            rollButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        // Activate initial constraints
        updateOrientationConstraints()
    }

    private func updateOrientationConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
        portraitCenterYConstraint?.isActive = false
        portraitTopConstraint?.isActive = false
        if currentOrientationIsPortrait {
            // For 1, 2, 3, or 4 dice, center vertically; for 5+, anchor to top
            if diceViews.count <= 4 {
                portraitCenterYConstraint?.isActive = true
            } else {
                portraitTopConstraint?.isActive = true
            }
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    private func setupMenu() {
        // Use self.view.window to get the window
        guard let window = self.view.window else {
            print("[DEBUG] No window found for menu manager in viewDidAppear")
            return
        }
        appWindow = window // Store reference
        // Only create menuManager if it doesn't exist
        if menuManager == nil {
            menuManager = MenuManager(window: window)
            // Add menu button to self.view instead of window
            self.view.addSubview(menuButton)
            menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
            // Restore original style
            menuButton.backgroundColor = .clear
            menuButton.layer.borderColor = nil
            menuButton.layer.borderWidth = 0
            menuButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
            menuButton.tintColor = .black
            // Add constraints for top right corner
            NSLayoutConstraint.activate([
                menuButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
                menuButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
                menuButton.widthAnchor.constraint(equalToConstant: 44),
                menuButton.heightAnchor.constraint(equalToConstant: 44)
            ])
            self.view.bringSubviewToFront(menuButton)
            // Setup menu button actions
            menuManager.setMenuButtonActions(
                onGameModeTapped: { [weak self] in
                    self?.presentPreferences()
                },
                onAccountTapped: { [weak self] in
                    // Handle account button tap
                }
            )
        }
        // Always bring menu button to front
        self.view.bringSubviewToFront(menuButton)
    }

    private func closeMenuIfOpen() {
        // If menuManager exists and menu is open, close it
        guard let menuManager = menuManager else { return }
        // The menu is open if sideMenuLeadingConstraint.constant < 0
        let mirror = Mirror(reflecting: menuManager)
        if let constraint = mirror.children.first(where: { $0.label == "sideMenuLeadingConstraint" })?.value as? NSLayoutConstraint {
            if constraint.constant < 0 {
                menuManager.closeMenuImmediately()
            }
        }
    }
    
    private func setupAudio() {
        guard let soundURL = Bundle.main.url(forResource: "dice_roll", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    private func presentPreferences() {
        let preferencesVC = PreferencesViewController()
        preferencesVC.modalPresentationStyle = .fullScreen
        present(preferencesVC, animated: true)
    }
    
    private func setupDice() {
        diceViews.forEach { $0.removeFromSuperview() }
        diceViews.removeAll()
        diceGridContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let diceCount = min(max(UserDefaultsManager.shared.diceCount, 1), 6)
        lastDiceCount = diceCount
        let isPortrait = currentOrientationIsPortrait

        if diceCount == 1 {
            // Center single dice in the middle row (portrait or landscape)
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.alignment = .center
            rowStack.distribution = .equalSpacing
            rowStack.spacing = 20
            let leftSpacer = UIView()
            let diceView = DiceView()
            diceView.translatesAutoresizingMaskIntoConstraints = false
            let rightSpacer = UIView()
            rowStack.addArrangedSubview(leftSpacer)
            rowStack.addArrangedSubview(diceView)
            rowStack.addArrangedSubview(rightSpacer)
            diceViews.append(diceView)
            NSLayoutConstraint.activate([
                leftSpacer.widthAnchor.constraint(equalToConstant: 100),
                diceView.widthAnchor.constraint(equalToConstant: 100),
                diceView.heightAnchor.constraint(equalToConstant: 100),
                rightSpacer.widthAnchor.constraint(equalToConstant: 100)
            ])
            diceGridContainer.addArrangedSubview(rowStack)
        } else if diceCount == 2 {
            // Center two dice in a single row
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.alignment = .center
            rowStack.distribution = .equalSpacing
            rowStack.spacing = 20
            for _ in 0..<2 {
                let diceView = DiceView()
                diceView.translatesAutoresizingMaskIntoConstraints = false
                rowStack.addArrangedSubview(diceView)
                diceViews.append(diceView)
                NSLayoutConstraint.activate([
                    diceView.widthAnchor.constraint(equalToConstant: 100),
                    diceView.heightAnchor.constraint(equalToConstant: 100)
                ])
            }
            diceGridContainer.addArrangedSubview(rowStack)
        } else if diceCount == 3 {
            // Triangle: top row center (1 dice), bottom row two dice, all centered as a block
            // Top row: single centered dice
            let topRow = UIStackView()
            topRow.axis = .horizontal
            topRow.alignment = .center
            topRow.distribution = .equalCentering
            topRow.spacing = 20
            let topDice = DiceView()
            topDice.translatesAutoresizingMaskIntoConstraints = false
            topRow.addArrangedSubview(topDice)
            diceViews.append(topDice)
            diceGridContainer.addArrangedSubview(topRow)
            NSLayoutConstraint.activate([
                topDice.widthAnchor.constraint(equalToConstant: 100),
                topDice.heightAnchor.constraint(equalToConstant: 100)
            ])
            // Bottom row: two dice, normal spacing
            let bottomRow = UIStackView()
            bottomRow.axis = .horizontal
            bottomRow.alignment = .center
            bottomRow.distribution = .equalSpacing
            bottomRow.spacing = 20
            for _ in 0..<2 {
                let diceView = DiceView()
                diceView.translatesAutoresizingMaskIntoConstraints = false
                bottomRow.addArrangedSubview(diceView)
                diceViews.append(diceView)
                NSLayoutConstraint.activate([
                    diceView.widthAnchor.constraint(equalToConstant: 100),
                    diceView.heightAnchor.constraint(equalToConstant: 100)
                ])
            }
            diceGridContainer.addArrangedSubview(bottomRow)
        } else if diceCount == 4 {
            // 2x2 square, all centered as a block
            for _ in 0..<2 {
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.alignment = .center
                rowStack.distribution = .equalSpacing
                rowStack.spacing = 20
                for _ in 0..<2 {
                    let diceView = DiceView()
                    diceView.translatesAutoresizingMaskIntoConstraints = false
                    rowStack.addArrangedSubview(diceView)
                    diceViews.append(diceView)
                    NSLayoutConstraint.activate([
                        diceView.widthAnchor.constraint(equalToConstant: 100),
                        diceView.heightAnchor.constraint(equalToConstant: 100)
                    ])
                }
                diceGridContainer.addArrangedSubview(rowStack)
            }
        } else if (diceCount == 5) && isPortrait {
            // Portrait: triangle layout: top row [spacer, dice, spacer], then two rows of two dice
            // Top row: single centered dice
            let topRow = UIStackView()
            topRow.axis = .horizontal
            topRow.alignment = .center
            topRow.distribution = .equalSpacing
            topRow.spacing = 20
            let leftSpacer = UIView()
            let topDice = DiceView()
            topDice.translatesAutoresizingMaskIntoConstraints = false
            let rightSpacer = UIView()
            topRow.addArrangedSubview(leftSpacer)
            topRow.addArrangedSubview(topDice)
            topRow.addArrangedSubview(rightSpacer)
            diceViews.append(topDice)
            NSLayoutConstraint.activate([
                leftSpacer.widthAnchor.constraint(equalToConstant: 100),
                topDice.widthAnchor.constraint(equalToConstant: 100),
                topDice.heightAnchor.constraint(equalToConstant: 100),
                rightSpacer.widthAnchor.constraint(equalToConstant: 100)
            ])
            diceGridContainer.addArrangedSubview(topRow)
            // Next two rows: two dice each
            for _ in 0..<2 {
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.alignment = .center
                rowStack.distribution = .equalSpacing
                rowStack.spacing = 20
                for _ in 0..<2 {
                    let diceView = DiceView()
                    diceView.translatesAutoresizingMaskIntoConstraints = false
                    rowStack.addArrangedSubview(diceView)
                    diceViews.append(diceView)
                    NSLayoutConstraint.activate([
                        diceView.widthAnchor.constraint(equalToConstant: 100),
                        diceView.heightAnchor.constraint(equalToConstant: 100)
                    ])
                }
                diceGridContainer.addArrangedSubview(rowStack)
            }
        } else if (diceCount == 6) && isPortrait {
            // Portrait: 3x2 grid (3 rows, 2 columns)
            let rows = 3, cols = 2
            var grid: [[DiceView?]] = Array(repeating: Array(repeating: nil, count: cols), count: rows)
            var dicePlaced = 0
            for row in 0..<rows {
                for col in 0..<cols {
                    if dicePlaced < diceCount {
                        let diceView = DiceView()
                        diceView.translatesAutoresizingMaskIntoConstraints = false
                        grid[row][col] = diceView
                        diceViews.append(diceView)
                        dicePlaced += 1
                    }
                }
            }
            for row in 0..<rows {
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.alignment = .center
                rowStack.distribution = .equalSpacing
                rowStack.spacing = 20
                for col in 0..<cols {
                    if let diceView = grid[row][col] {
                        rowStack.addArrangedSubview(diceView)
                        NSLayoutConstraint.activate([
                            diceView.widthAnchor.constraint(equalToConstant: 100),
                            diceView.heightAnchor.constraint(equalToConstant: 100)
                        ])
                    } else {
                        let spacer = UIView()
                        spacer.translatesAutoresizingMaskIntoConstraints = false
                        rowStack.addArrangedSubview(spacer)
                        NSLayoutConstraint.activate([
                            spacer.widthAnchor.constraint(equalToConstant: 100),
                            spacer.heightAnchor.constraint(equalToConstant: 100)
                        ])
                    }
                }
                diceGridContainer.addArrangedSubview(rowStack)
            }
        } else if (diceCount == 5 || diceCount == 6) && !isPortrait {
            // Landscape: 2x3 grid (2 rows, 3 columns)
            let rows = 2, cols = 3
            var grid: [[DiceView?]] = Array(repeating: Array(repeating: nil, count: cols), count: rows)
            var dicePlaced = 0
            for row in 0..<rows {
                for col in 0..<cols {
                    if dicePlaced < diceCount {
                        let diceView = DiceView()
                        diceView.translatesAutoresizingMaskIntoConstraints = false
                        grid[row][col] = diceView
                        diceViews.append(diceView)
                        dicePlaced += 1
                    }
                }
            }
            for row in 0..<rows {
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.alignment = .center
                rowStack.distribution = .equalSpacing
                rowStack.spacing = 20
                for col in 0..<cols {
                    if let diceView = grid[row][col] {
                        rowStack.addArrangedSubview(diceView)
                        NSLayoutConstraint.activate([
                            diceView.widthAnchor.constraint(equalToConstant: 100),
                            diceView.heightAnchor.constraint(equalToConstant: 100)
                        ])
                    } else {
                        let spacer = UIView()
                        spacer.translatesAutoresizingMaskIntoConstraints = false
                        rowStack.addArrangedSubview(spacer)
                        NSLayoutConstraint.activate([
                            spacer.widthAnchor.constraint(equalToConstant: 100),
                            spacer.heightAnchor.constraint(equalToConstant: 100)
                        ])
                    }
                }
                diceGridContainer.addArrangedSubview(rowStack)
            }
        } else {
            // Even: fill pairs from top to bottom, left and right (fallback for >6)
            let rows = 3, cols = 2
            var grid: [[DiceView?]] = Array(repeating: Array(repeating: nil, count: cols), count: rows)
            var dicePlaced = 0
            for row in 0..<rows {
                for col in 0..<cols {
                    if dicePlaced < diceCount {
                        let diceView = DiceView()
                        diceView.translatesAutoresizingMaskIntoConstraints = false
                        grid[row][col] = diceView
                        diceViews.append(diceView)
                        dicePlaced += 1
                    }
                }
            }
            for row in 0..<rows {
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.spacing = 20
                rowStack.alignment = .center
                rowStack.distribution = .equalSpacing
                for col in 0..<cols {
                    if let diceView = grid[row][col] {
                        rowStack.addArrangedSubview(diceView)
                        NSLayoutConstraint.activate([
                            diceView.widthAnchor.constraint(equalToConstant: 100),
                            diceView.heightAnchor.constraint(equalToConstant: 100)
                        ])
                    } else {
                        let spacer = UIView()
                        spacer.translatesAutoresizingMaskIntoConstraints = false
                        rowStack.addArrangedSubview(spacer)
                        NSLayoutConstraint.activate([
                            spacer.widthAnchor.constraint(equalToConstant: 100),
                            spacer.heightAnchor.constraint(equalToConstant: 100)
                        ])
                    }
                }
                diceGridContainer.addArrangedSubview(rowStack)
            }
        }
    }
    
    @objc private func menuButtonTapped() {
        menuManager.toggleMenu()
    }
    
    @objc private func rollButtonTapped() {
        guard !isRolling else { return }
        isRolling = true
        rollButton.isEnabled = false
        // Play sound only if not muted
        if !UserDefaultsManager.shared.muteSound {
            audioPlayer?.currentTime = 0
            audioPlayer?.play()
        }
        // Roll all dice
        diceViews.forEach { $0.roll() }
        // Enable button after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isRolling = false
            self?.rollButton.isEnabled = true
        }
    }
}

