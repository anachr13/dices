import UIKit
import QuartzCore

class DiceView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var currentValue: Int = Int.random(in: 1...6) {
        didSet {
            updateDiceImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 0
        layer.borderWidth = 0
        layer.borderColor = nil
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
        
        updateDiceImage()
    }
    
    private func updateDiceImage() {
        imageView.image = UIImage(systemName: "die.face.\(currentValue)")
        imageView.tintColor = .black
    }
    
    func roll() {
        // Remove any existing animations
        layer.removeAllAnimations()

        // Add rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 0.5
        rotationAnimation.repeatCount = 2

        // Add scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2
        scaleAnimation.duration = 0.25
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = 2

        // Add animations to layer
        layer.add(rotationAnimation, forKey: "rotationAnimation")
        layer.add(scaleAnimation, forKey: "scaleAnimation")

        // Animate dice face changing rapidly
        let animationDuration = 1.0
        let interval = 0.08
        let changes = Int(animationDuration / interval)
        for i in 0..<changes {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) { [weak self] in
                self?.currentValue = Int.random(in: 1...6)
            }
        }
        // Settle on final value after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.currentValue = Int.random(in: 1...6)
        }
    }
} 