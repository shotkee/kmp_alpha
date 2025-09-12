//
//  WelcomeViewController.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 1/31/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

final class WelcomeViewController: ViewController,
                                   ApplicationSettingsServiceDependency {
    var applicationSettingsService: ApplicationSettingsService!
    
    struct Notify {
        let showEsiaSignInButton: (_ show: Bool) -> Void
    }
    
    private(set) lazy var notify = Notify(
        showEsiaSignInButton: { [weak self] show in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.esiaSignInButton.isHidden = !show
        }
    )
    
    struct Input {
        let appear: () -> Void
    }
    
    var input: Input!
    
    struct Output {
        let showMain: () -> Void
        let showActivateInsurance: () -> Void
        let showSignIn: () -> Void
        let showRegistration: () -> Void
        let startDemoMode: () -> Void
        let chat: () -> Void
        let buyInsurance: () -> Void
        let showEsiaSignIn: () -> Void
    }
    
    var output: Output!
    
    private lazy var skipButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(skipTap(_:)))
        button <~ Style.Button.NavigationItemDarkGray(title: NSLocalizedString("common_skip_button", comment: ""))
        return button
    }()
    
    private let screenTipLabel = UILabel()
    private let registerButton = RoundEdgeButton()
    private let signInButton = RoundEdgeButton()
    private let infoLabel = UILabel()
    private let titleLabel = UILabel()
    private let esiaSignInButton = RoundEdgeButton()
    private let logoImageView = UIImageView()
    private let buyActionView = SosActionView.fromNib()
    private let chatActionView = SosActionView.fromNib()
    private let demoModeActionView = SosActionView.fromNib()
    private let activateActionView = SosActionView.fromNib()
    
    private let smallCardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 9
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: is7IphoneOrLess() ? 18 : 32, left: 18, bottom: 24, right: 18)
        
        return stackView
    }()
    
    private lazy var actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 9
        stackView.isLayoutMarginsRelativeArrangement = true
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        input.appear()
    }

    @objc private func skipTap(_ sender: UIButton) {
        analytics.track(event: AnalyticsEvent.Launch.skipSignIn)
        output.showMain()
    }

    @objc private func signInTap(_ sender: UIButton) {
        analytics.track(event: AnalyticsEvent.Launch.openSignIn)
        output.showSignIn()
    }

    @objc private func registerTap(_ sender: UIButton) {
        analytics.track(event: AnalyticsEvent.Launch.openRegister)
        output.showRegistration()
    }
    
    @objc private func signEsiaInTap(_ sender: UIButton) {
        analytics.track(event: AnalyticsEvent.Launch.openSignIn)
        output.showEsiaSignIn()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .Background.backgroundContent
        
        navigationItem.rightBarButtonItem = skipButton
        
        view.addSubview(actionButtonsStackView)
        actionButtonsStackView.edgesToSuperview(excluding: .top, insets: insets(18))
        
        view.addSubview(contentStackView)
        contentStackView.topToSuperview(usingSafeArea: true)
        contentStackView.leadingToSuperview()
        contentStackView.trailingToSuperview()
        contentStackView.bottomToTop(of: actionButtonsStackView, relation: .equalOrLess)
        
        let imageViewContainer = UIView()
        contentStackView.addArrangedSubview(imageViewContainer)
        
        imageViewContainer.addSubview(logoImageView)
		logoImageView.image = .Icons.alfa
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.width(56)
        logoImageView.heightToWidth(of: logoImageView)
        logoImageView.topToSuperview()
        logoImageView.bottomToSuperview()
        logoImageView.centerXToSuperview()
        
        contentStackView.addArrangedSubview(spacer(20))
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(spacer(is7IphoneOrLess() ? 32 : 42))
        contentStackView.addArrangedSubview(smallCardsStackView)

        let topLineStackView = UIStackView()
        topLineStackView.axis = .horizontal
        topLineStackView.distribution = .fillEqually
        topLineStackView.spacing = 15
        smallCardsStackView.addArrangedSubview(topLineStackView)
        
        topLineStackView.height(78)
        
        topLineStackView.addArrangedSubview(CardView(contentView: buyActionView))
        buyActionView.set(
            title: NSLocalizedString("welcome_buy_insurance", comment: ""),
            icon: .Icons.wallet.tintedImage(withColor: .Icons.iconAccent)
        ) { [weak self] in
            self?.output.buyInsurance()
        }

        topLineStackView.addArrangedSubview(CardView(contentView: chatActionView))
        chatActionView.set(
            title: NSLocalizedString("welcome_chat_title", comment: ""),
            icon: .Icons.chat.tintedImage(withColor: .Icons.iconAccent)
        ) { [weak self] in
            self?.output.chat()
        }

        let bottomLineStackView = UIStackView()
        bottomLineStackView.axis = .horizontal
        bottomLineStackView.distribution = .fillEqually
        bottomLineStackView.spacing = 15
        smallCardsStackView.addArrangedSubview(bottomLineStackView)
        
        bottomLineStackView.height(78)
        
        bottomLineStackView.addArrangedSubview(CardView(contentView: demoModeActionView))
        demoModeActionView.set(
            title: NSLocalizedString("welcome_demo_mode", comment: ""),
            icon: .Icons.more.tintedImage(withColor: .Icons.iconAccent)
        ) { [weak self] in
            self?.analytics.track(event: AnalyticsEvent.Launch.signInDemo)
            self?.output.startDemoMode()
        }

        bottomLineStackView.addArrangedSubview(CardView(contentView: activateActionView))
        activateActionView.set(
            title: NSLocalizedString("welcome_activate_insurance", comment: ""),
            icon: .Icons.lock.tintedImage(withColor: .Icons.iconAccent)
        ) { [weak self] in
            self?.analytics.track(event: AnalyticsEvent.Launch.openActivate)
            self?.output.showActivateInsurance()
        }
        
        registerButton <~ Style.RoundedButton.oldOutlinedButtonSmall
        registerButton.setTitle(NSLocalizedString("welcome_register", comment: ""), for: .normal)
        registerButton.addTarget(self, action: #selector(registerTap), for: .touchUpInside)
        registerButton.height(48)
        
        signInButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        signInButton.setTitle(NSLocalizedString("welcome_sign_in", comment: ""), for: .normal)
        signInButton.addTarget(self, action: #selector(signInTap), for: .touchUpInside)
        signInButton.height(48)
        
        esiaSignInButton <~ Style.RoundedButton.oldOutlinedButtonSmall
        esiaSignInButton.setTitle(NSLocalizedString("welcome_esia_sign_in", comment: ""), for: .normal)
        esiaSignInButton.addTarget(self, action: #selector(signEsiaInTap), for: .touchUpInside)
        esiaSignInButton.height(48)
        esiaSignInButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
        esiaSignInButton.setImage(UIImage(named: "icon-esia-logo"), for: .normal)

        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("welcome_title", comment: "")
        titleLabel.textAlignment = .center
        
        actionButtonsStackView.addArrangedSubview(registerButton)
        actionButtonsStackView.addArrangedSubview(esiaSignInButton)
        actionButtonsStackView.addArrangedSubview(signInButton)
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        buyActionView.set(icon: .Icons.wallet.tintedImage(withColor: .Icons.iconAccent))
        chatActionView.set(icon: .Icons.chat.tintedImage(withColor: .Icons.iconAccent))
        demoModeActionView.set(icon: .Icons.more.tintedImage(withColor: .Icons.iconAccent))
        activateActionView.set(icon: .Icons.lock.tintedImage(withColor: .Icons.iconAccent))
    }
}
