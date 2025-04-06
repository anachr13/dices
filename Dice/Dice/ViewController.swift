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
}

