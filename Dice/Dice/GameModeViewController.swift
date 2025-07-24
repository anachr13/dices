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
    
    private var menuManager: MenuManager!
    
    // Dice count controls
    private let diceCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Number of Dice"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let diceCountValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        return button
    }()
    
    private var currentDiceCount: Int = 2 {
        didSet {
            updateDiceCountUI()
        }
    }
    
    private let muteSoundSwitch: UISwitch = {
        let muteSwitch = UISwitch()
        muteSwitch.translatesAutoresizingMaskIntoConstraints = false
        muteSwitch.onTintColor = .black
        return muteSwitch
    }()
    
    private let alwaysOnScreenSwitch: UISwitch = {
        let alwaysSwitch = UISwitch()
        alwaysSwitch.translatesAutoresizingMaskIntoConstraints = false
        alwaysSwitch.onTintColor = .black
        return alwaysSwitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDiceCount = UserDefaultsManager.shared.diceCount
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Preferences"
        
        // Setup menu
        setupMenu()
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add save button
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Dice Count Section
        let diceCountSection = createDiceCountSection()
        // Bagamon Beast Mode Section (omit/remove)
        // let bagamonSection = createSection(
        //     title: "Bagamon Beast Mode",
        //     subtitle: "When you have double digits a fun message will apear on the screen"
        // )
        // Mute Sound Section
        let muteSoundSection = createMuteSoundSection()
        // Always on Screen Section
        let alwaysOnSection = createAlwaysOnScreenSection()
        // Add sections to content view
        contentView.addArrangedSubview(diceCountSection)
        // contentView.addArrangedSubview(bagamonSection) // OMITTED
        contentView.addArrangedSubview(muteSoundSection)
        contentView.addArrangedSubview(alwaysOnSection)
        
        // Add padding to content view
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        contentView.isLayoutMarginsRelativeArrangement = true
        
        // Setup constraints
        NSLayoutConstraint.activate([
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
    
    private func setupMenu() {
        // Get the main window
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first else {
            print("No window found for menu manager")
            return
        }
        // Create menu manager
        menuManager = MenuManager(window: window)
        
        // Add menu button
        view.addSubview(menuButton)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        // Ensure menu button is always on top
        view.bringSubviewToFront(menuButton)
        
        // Setup menu button constraints
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            menuButton.widthAnchor.constraint(equalToConstant: 44),
            menuButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Setup menu button actions
        menuManager.setMenuButtonActions(
            onGameModeTapped: { [weak self] in
                self?.menuButtonTapped()
            },
            onAccountTapped: { [weak self] in
                // Handle account button tap
            }
        )
    }
    
    private func createDiceCountSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Add title label
        diceCountLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add controls container
        let controlsContainer = UIStackView()
        controlsContainer.axis = .horizontal
        controlsContainer.spacing = 20
        controlsContainer.alignment = .center
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addArrangedSubview(minusButton)
        controlsContainer.addArrangedSubview(diceCountValueLabel)
        controlsContainer.addArrangedSubview(plusButton)

        // Horizontal stack for title and controls
        let rowStack = UIStackView(arrangedSubviews: [diceCountLabel, controlsContainer])
        rowStack.axis = .horizontal
        rowStack.spacing = 16
        rowStack.alignment = .center
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        // Subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Number of rolling dices"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0

        // Vertical stack for row and subtitle
        let verticalStack = UIStackView(arrangedSubviews: [rowStack, subtitleLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(verticalStack)

        // Setup button actions
        minusButton.addTarget(self, action: #selector(decreaseDiceCount), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increaseDiceCount), for: .touchUpInside)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 44),
            minusButton.heightAnchor.constraint(equalToConstant: 44),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            plusButton.heightAnchor.constraint(equalToConstant: 44),
            diceCountValueLabel.widthAnchor.constraint(equalToConstant: 60)
        ])

        // Update initial UI
        updateDiceCountUI()

        return container
    }
    
    private func createMuteSoundSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Rolling sound"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Enable or disable the dice rolling sound."
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(muteSoundSwitch)
        muteSoundSwitch.isOn = !UserDefaultsManager.shared.muteSound
        muteSoundSwitch.addTarget(self, action: #selector(muteSoundSwitchChanged), for: .valueChanged)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: muteSoundSwitch.leadingAnchor, constant: -8),
            // Switch alignment
            muteSoundSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            muteSoundSwitch.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
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
    
    private func createAlwaysOnScreenSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Always on Screen"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Screen always on after inactivity"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(alwaysOnScreenSwitch)
        alwaysOnScreenSwitch.isOn = UserDefaultsManager.shared.alwaysOnScreen
        alwaysOnScreenSwitch.addTarget(self, action: #selector(alwaysOnScreenSwitchChanged), for: .valueChanged)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: alwaysOnScreenSwitch.leadingAnchor, constant: -8),
            // Switch alignment
            alwaysOnScreenSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            alwaysOnScreenSwitch.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }
    
    private func updateDiceCountUI() {
        diceCountValueLabel.text = "\(currentDiceCount)"
        minusButton.isEnabled = currentDiceCount > 1
        plusButton.isEnabled = currentDiceCount < 6
        minusButton.alpha = minusButton.isEnabled ? 1.0 : 0.5
        plusButton.alpha = plusButton.isEnabled ? 1.0 : 0.5
    }
    
    @objc private func decreaseDiceCount() {
        guard currentDiceCount > 1 else { return }
        currentDiceCount -= 1
    }
    
    @objc private func increaseDiceCount() {
        guard currentDiceCount < 6 else { return }
        currentDiceCount += 1
    }
    
    @objc private func muteSoundSwitchChanged() {
        UserDefaultsManager.shared.muteSound = !muteSoundSwitch.isOn
    }
    
    @objc private func alwaysOnScreenSwitchChanged() {
        UserDefaultsManager.shared.alwaysOnScreen = alwaysOnScreenSwitch.isOn
    }
    
    @objc private func menuButtonTapped() {
        menuManager.toggleMenu()
    }
    
    @objc private func saveButtonTapped() {
        UserDefaultsManager.shared.diceCount = currentDiceCount
        dismiss(animated: true)
    }
} 