import UIKit

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
    
    // MARK: - Initialization
    init(window: UIWindow) {
        self.window = window
        self.sideMenuView = SideMenuView()
        self.dimView = UIView()
        super.init()
        setupUI()
    }
    
    // MARK: - Setup
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
    
    // MARK: - Public Methods
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

    func closeMenuImmediately() {
        sideMenuLeadingConstraint.constant = 0
        dimView.alpha = 0
        window?.layoutIfNeeded()
    }
    
    func setMenuButtonActions(onGameModeTapped: @escaping () -> Void, onAccountTapped: @escaping () -> Void) {
        sideMenuView.onGameModeTapped = onGameModeTapped
        sideMenuView.onAccountTapped = onAccountTapped
    }
    
    // MARK: - Actions
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