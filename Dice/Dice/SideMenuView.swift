import UIKit

class SideMenuView: UIView {
    // MARK: - Properties
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let image = UIImage(named: "dice_white_logo") {
            imageView.image = image
        } else {
            print("Logo image not found")
        }
        return imageView
    }()
    
    private let gameModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Preferences", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let accountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    var onGameModeTapped: (() -> Void)?
    var onAccountTapped: (() -> Void)?
    var onMenuStateChanged: ((Bool) -> Void)?
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        addSubview(logoImageView)
        addSubview(gameModeButton)
        addSubview(accountButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Logo constraints
            logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Game Mode button constraints
            gameModeButton.bottomAnchor.constraint(equalTo: accountButton.topAnchor, constant: -20),
            gameModeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            gameModeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            gameModeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Account button constraints
            accountButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -60),
            accountButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            accountButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            accountButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add button actions
        gameModeButton.addTarget(self, action: #selector(gameModeButtonTapped), for: .touchUpInside)
        accountButton.addTarget(self, action: #selector(accountButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func gameModeButtonTapped() {
        onGameModeTapped?()
    }
    
    @objc private func accountButtonTapped() {
        onAccountTapped?()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create curved corner mask
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath()
        let cornerRadius: CGFloat = 20
        
        // Start from the top-left corner
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        
        // Add the curved corner
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0),
                         controlPoint: CGPoint(x: 0, y: 0))
        
        // Add the top line
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        
        // Add the right line
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        
        // Add the bottom line
        path.addLine(to: CGPoint(x: 0, y: bounds.height))
        
        // Close the path
        path.close()
        
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
} 