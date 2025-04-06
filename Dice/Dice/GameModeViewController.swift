import UIKit

class PreferencesViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save & Return", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let sideMenuView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private var sideMenuLeadingConstraint: NSLayoutConstraint!
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Preferences"
        
        // Add menu button
        view.addSubview(menuButton)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        // Add dimming view
        view.addSubview(dimView)
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add save button
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add side menu
        view.addSubview(sideMenuView)
        setupSideMenu()
        
        // Ensure side menu is always on top
        view.bringSubviewToFront(sideMenuView)
        view.bringSubviewToFront(menuButton)
        
        // Add tap gesture to close menu
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideMenu))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        // Dice Number Section
        let diceNumberSection = createSection(
            title: "Dice Number",
            subtitle: "Select Number of dices, it can be ether one or two"
        )
        
        // Bagamon Beast Mode Section
        let bagamonSection = createSection(
            title: "Bagamon Beast Mode",
            subtitle: "When you have double digits a fun message will apear on the screen"
        )
        
        // Mute Sound Section
        let muteSoundSection = createSection(
            title: "Mute Sound",
            subtitle: "Disable sound after rolloing"
        )
        
        // Always on Screen Section
        let alwaysOnSection = createSection(
            title: "Always on Screen",
            subtitle: "Have the screen always on after inactivity"
        )
        
        // Add sections to content view
        contentView.addArrangedSubview(diceNumberSection)
        contentView.addArrangedSubview(bagamonSection)
        contentView.addArrangedSubview(muteSoundSection)
        contentView.addArrangedSubview(alwaysOnSection)
        
        // Add padding to content view
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        contentView.isLayoutMarginsRelativeArrangement = true
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Menu button constraints
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            menuButton.widthAnchor.constraint(equalToConstant: 44),
            menuButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Dimming view constraints
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Save button constraints
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupSideMenu() {
        // Add logo to side menu
        sideMenuView.addSubview(logoImageView)
        
        // Add menu items
        let preferencesButton = createMenuItem(title: "Preferences")
        let accountButton = createMenuItem(title: "Account")
        
        // Add buttons directly to side menu
        sideMenuView.addSubview(preferencesButton)
        sideMenuView.addSubview(accountButton)
        
        // Constraints
        sideMenuLeadingConstraint = sideMenuView.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        
        NSLayoutConstraint.activate([
            sideMenuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideMenuView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            sideMenuLeadingConstraint,
            
            // Logo constraints
            logoImageView.topAnchor.constraint(equalTo: sideMenuView.topAnchor, constant: 20),
            logoImageView.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Preferences button constraints
            preferencesButton.bottomAnchor.constraint(equalTo: accountButton.topAnchor, constant: -20),
            preferencesButton.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor, constant: 20),
            preferencesButton.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor, constant: -20),
            preferencesButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Account button constraints
            accountButton.bottomAnchor.constraint(equalTo: sideMenuView.bottomAnchor, constant: -60),
            accountButton.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor, constant: 20),
            accountButton.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor, constant: -20),
            accountButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Set initial position (hidden)
        sideMenuLeadingConstraint.constant = 0
    }
    
    private func createMenuItem(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.contentHorizontalAlignment = .left
        return button
    }
    
    private func createSection(title: String, subtitle: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    @objc private func menuButtonTapped() {
        // Toggle side menu
        if sideMenuLeadingConstraint.constant == 0 {
            // Open menu
            sideMenuLeadingConstraint.constant = -view.bounds.width * 0.7
            // Ensure menu is on top when opening
            view.bringSubviewToFront(dimView)
            view.bringSubviewToFront(sideMenuView)
            view.bringSubviewToFront(menuButton)
            
            // Animate the dimming view
            UIView.animate(withDuration: 0.3) {
                self.dimView.alpha = 0.5
            }
        } else {
            // Close menu
            sideMenuLeadingConstraint.constant = 0
            
            // Animate the dimming view
            UIView.animate(withDuration: 0.3) {
                self.dimView.alpha = 0
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleTapOutsideMenu(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !sideMenuView.frame.contains(location) && sideMenuLeadingConstraint.constant != 0 {
            menuButtonTapped()
        }
    }
    
    @objc private func saveButtonTapped() {
        // TODO: Save settings
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the mask path with the correct bounds
        if let maskLayer = sideMenuView.layer.mask as? CAShapeLayer {
            let path = UIBezierPath()
            let cornerRadius: CGFloat = 20
            
            // Start from the top-left corner
            path.move(to: CGPoint(x: 0, y: cornerRadius))
            
            // Add the curved corner
            path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0),
                             controlPoint: CGPoint(x: 0, y: 0))
            
            // Add the top line
            path.addLine(to: CGPoint(x: sideMenuView.bounds.width, y: 0))
            
            // Add the right line
            path.addLine(to: CGPoint(x: sideMenuView.bounds.width, y: sideMenuView.bounds.height))
            
            // Add the bottom line
            path.addLine(to: CGPoint(x: 0, y: sideMenuView.bounds.height))
            
            // Close the path
            path.close()
            
            maskLayer.path = path.cgPath
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PreferencesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        return !sideMenuView.frame.contains(location) && sideMenuLeadingConstraint.constant != 0
    }
} 