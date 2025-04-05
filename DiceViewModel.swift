import SwiftUI
import AVFoundation

class DiceViewModel: ObservableObject {
    @Published var leftDiceNumber = 1
    @Published var rightDiceNumber = 1
    @Published var isRolling = false
    
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        guard let soundURL = Bundle.main.url(forResource: "dice_roll", withExtension: "mp3") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    func rollDice() {
        isRolling = true
        audioPlayer?.play()
        
        // Simulate rolling animation
        let animationDuration = 0.6
        let updateInterval = 0.05
        let totalUpdates = Int(animationDuration / updateInterval)
        var currentUpdate = 0
        
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            self.leftDiceNumber = Int.random(in: 1...6)
            self.rightDiceNumber = Int.random(in: 1...6)
            
            currentUpdate += 1
            if currentUpdate >= totalUpdates {
                timer.invalidate()
                self.isRolling = false
            }
        }
    }
} 