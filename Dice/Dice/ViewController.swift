//
//  ViewController.swift
//  Dice
//
//  Created by Christos Anastasiades on 6/4/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    private let leftDiceImageView = UIImageView()
    private let rightDiceImageView = UIImageView()
    private let rollButton = UIButton(type: .system)
    private var audioPlayer: AVAudioPlayer?
    private var isRolling = false
    
    // Menu properties
    private let menuButton = UIButton(type: .system)
    private let sideMenuView = UIView()
    private let menuItemsStackView = UIStackView()
    private var isMenuOpen = false
    private var sideMenuLeadingConstraint: NSLayoutConstraint!
    
    override func loadView() {
        super.loadView()
        print("🔍 loadView called")
        print("🔍 View frame: \(view.frame)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 viewDidLoad called")
        print("🔍 View frame: \(view.frame)")
        
        // Set background color
        view.backgroundColor = .white
        view.isOpaque = true
        print("🔍 Background color set to white")
        
        // Setup dice image views
        setupDiceViews()
        
        // Setup roll button
        setupRollButton()
        
        // Setup audio
        setupAudio()
        
        // Setup menu button and side menu (after other views)
        setupMenuButton()
        setupSideMenu()
        
        // Force layout update
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🔍 viewWillAppear called")
        print("🔍 View frame: \(view.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🔍 viewDidAppear called")
        print("🔍 View frame: \(view.frame)")
        print("🔍 Left dice frame: \(leftDiceImageView.frame)")
        print("🔍 Right dice frame: \(rightDiceImageView.frame)")
        print("🔍 Button frame: \(rollButton.frame)")
        
        // Force layout update
        view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("🔍 viewDidLayoutSubviews called")
        print("🔍 View frame: \(view.frame)")
        print("🔍 Left dice frame: \(leftDiceImageView.frame)")
        print("🔍 Right dice frame: \(rightDiceImageView.frame)")
        print("🔍 Button frame: \(rollButton.frame)")
        
        // Update curved corner mask
        let cornerRadius: CGFloat = 20
        let path = UIBezierPath()
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: sideMenuView.bounds.width, y: 0))
        path.addLine(to: CGPoint(x: sideMenuView.bounds.width, y: sideMenuView.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: sideMenuView.bounds.height))
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0),
                         controlPoint: CGPoint(x: 0, y: 0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        sideMenuView.layer.mask = maskLayer
    }
    
    private func setupDiceViews() {
        print("Setting up dice views")
        
        // Left dice
        leftDiceImageView.translatesAutoresizingMaskIntoConstraints = false
        leftDiceImageView.contentMode = .scaleAspectFit
        leftDiceImageView.image = UIImage(systemName: "die.face.1")
        leftDiceImageView.tintColor = .black
        leftDiceImageView.isOpaque = true
        view.addSubview(leftDiceImageView)
        
        // Right dice
        rightDiceImageView.translatesAutoresizingMaskIntoConstraints = false
        rightDiceImageView.contentMode = .scaleAspectFit
        rightDiceImageView.image = UIImage(systemName: "die.face.1")
        rightDiceImageView.tintColor = .black
        rightDiceImageView.isOpaque = true
        view.addSubview(rightDiceImageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Left dice
            leftDiceImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            leftDiceImageView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            leftDiceImageView.widthAnchor.constraint(equalToConstant: 100),
            leftDiceImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Right dice
            rightDiceImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rightDiceImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            rightDiceImageView.widthAnchor.constraint(equalToConstant: 100),
            rightDiceImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        print("Dice views setup complete")
    }
    
    private func setupRollButton() {
        print("Setting up roll button")
        
        rollButton.translatesAutoresizingMaskIntoConstraints = false
        rollButton.setTitle("Roll Dice", for: .normal)
        rollButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        rollButton.setTitleColor(.white, for: .normal)
        rollButton.backgroundColor = .black
        rollButton.layer.cornerRadius = 10
        rollButton.isOpaque = true
        rollButton.addTarget(self, action: #selector(rollDice), for: .touchUpInside)
        view.addSubview(rollButton)
        
        NSLayoutConstraint.activate([
            rollButton.topAnchor.constraint(equalTo: leftDiceImageView.bottomAnchor, constant: 30),
            rollButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rollButton.widthAnchor.constraint(equalToConstant: 120),
            rollButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        print("Roll button setup complete")
    }
    
    private func setupAudio() {
        print("🔊 Setting up audio...")
        
        // First, check if the sound file exists in the bundle
        guard let soundURL = Bundle.main.url(forResource: "dice_roll", withExtension: "mp3") else {
            print("❌ Sound file not found in bundle")
            print("🔍 Bundle path: \(Bundle.main.bundlePath)")
            print("🔍 Bundle contents: \(try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath))")
            return
        }
        
        print("✅ Found sound file at: \(soundURL.path)")
        
        do {
            // Configure audio session
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured")
            
            // Create and setup audio player
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            print("✅ Audio player setup successfully")
            
            // Test play
            audioPlayer?.play()
            print("✅ Test play successful")
            
        } catch {
            print("❌ Error setting up audio: \(error.localizedDescription)")
        }
    }
    
    @objc private func rollDice() {
        guard !isRolling else { return }
        print("🎲 Rolling dice")
        
        isRolling = true
        rollButton.isEnabled = false
        
        // Play sound with error handling
        if let player = audioPlayer {
            if player.play() {
                print("🔊 Playing sound")
            } else {
                print("❌ Failed to play sound")
            }
        } else {
            print("❌ Audio player is nil")
        }
        
        // Animate both dice
        animateDice(leftDiceImageView)
        animateDice(rightDiceImageView)
        
        // Stop after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.stopAnimation()
        }
    }
    
    private func animateDice(_ imageView: UIImageView) {
        // Add rotation animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 0.2
        rotation.repeatCount = 5
        
        // Add shake animation
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.repeatCount = 20
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: imageView.center.x - 5, y: imageView.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: imageView.center.x + 5, y: imageView.center.y))
        
        imageView.layer.add(rotation, forKey: "rotation")
        imageView.layer.add(shake, forKey: "shake")
        
        // Change dice faces during animation
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let randomNumber = Int.random(in: 1...6)
            imageView.image = UIImage(systemName: "die.face.\(randomNumber)")
            
            count += 1
            if count >= 10 {
                timer.invalidate()
            }
        }
    }
    
    private func stopAnimation() {
        isRolling = false
        rollButton.isEnabled = true
        
        // Set final random numbers
        let leftNumber = Int.random(in: 1...6)
        let rightNumber = Int.random(in: 1...6)
        
        leftDiceImageView.image = UIImage(systemName: "die.face.\(leftNumber)")
        rightDiceImageView.image = UIImage(systemName: "die.face.\(rightNumber)")
        
        // Remove animations
        leftDiceImageView.layer.removeAllAnimations()
        rightDiceImageView.layer.removeAllAnimations()
    }
    
    private func setupMenuButton() {
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        menuButton.tintColor = .black
        menuButton.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        view.addSubview(menuButton)
        
        // Ensure menu button is always on top
        view.bringSubviewToFront(menuButton)
        
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            menuButton.widthAnchor.constraint(equalToConstant: 44),
            menuButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupSideMenu() {
        // Side menu container
        sideMenuView.backgroundColor = .black
        sideMenuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideMenuView)
        
        // Ensure side menu is always on top
        view.bringSubviewToFront(sideMenuView)
        view.bringSubviewToFront(menuButton)
        
        // Add logo
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Try to load the logo image with error handling
        if let logoImage = UIImage(named: "dice_white_logo") {
            print("✅ Logo image loaded successfully")
            logoImageView.image = logoImage
        } else {
            print("❌ Failed to load logo image")
            // Add a placeholder or debug view
            logoImageView.backgroundColor = .gray
            let label = UILabel()
            label.text = "Logo"
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            logoImageView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: logoImageView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor)
            ])
        }
        
        logoImageView.contentMode = .scaleAspectFit
        sideMenuView.addSubview(logoImageView)
        
        // Add menu items
        let gameModeButton = createMenuItem(title: "Game Mode")
        let accountButton = createMenuItem(title: "Account")
        
        // Add buttons directly to side menu
        sideMenuView.addSubview(gameModeButton)
        sideMenuView.addSubview(accountButton)
        
        // Constraints
        sideMenuLeadingConstraint = sideMenuView.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        
        NSLayoutConstraint.activate([
            sideMenuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideMenuView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            sideMenuLeadingConstraint,
            
            // Logo constraints - moved to left
            logoImageView.topAnchor.constraint(equalTo: sideMenuView.topAnchor, constant: 20),
            logoImageView.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Account button constraints (bottom button)
            accountButton.bottomAnchor.constraint(equalTo: sideMenuView.bottomAnchor, constant: -60),
            accountButton.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor, constant: 20),
            accountButton.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor, constant: -20),
            accountButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Game Mode button constraints (above Account)
            gameModeButton.bottomAnchor.constraint(equalTo: accountButton.topAnchor, constant: -20),
            gameModeButton.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor, constant: 20),
            gameModeButton.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor, constant: -20),
            gameModeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add tap gesture to close menu
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideMenu))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func createMenuItem(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(menuItemTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func handleTapOutsideMenu(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !sideMenuView.frame.contains(location) && isMenuOpen {
            toggleMenu()
        }
    }
    
    @objc private func toggleMenu() {
        isMenuOpen.toggle()
        print("Menu toggled: \(isMenuOpen ? "open" : "closed")")
        
        // Disable other interactions while menu is open
        rollButton.isUserInteractionEnabled = !isMenuOpen
        leftDiceImageView.isUserInteractionEnabled = !isMenuOpen
        rightDiceImageView.isUserInteractionEnabled = !isMenuOpen
        
        UIView.animate(withDuration: 0.3) {
            self.sideMenuLeadingConstraint.constant = self.isMenuOpen ? -self.view.frame.width * 0.7 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func menuItemTapped(_ sender: UIButton) {
        print("Menu item tapped: \(sender.currentTitle ?? "")")
        // Handle menu item taps here
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        return !sideMenuView.frame.contains(location) && isMenuOpen
    }
}

