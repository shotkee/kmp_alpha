//
//  ProfileViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/1/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ProfileViewController: ViewController {
    private enum Constants {
        static let defaultOffset: CGFloat = 18
        static let iphoneSEScreenWidth: CGFloat = 320
        static var changeAccountViewHeight: CGFloat {
            if UIScreen.main.bounds.width > iphoneSEScreenWidth {
                return 123
            } else {
                return 171
            }
        }
    }

    struct Input {
        let account: (_ completion: @escaping (Account) -> Void) -> Void
        let isAuthorized: () -> Bool
		let isDemoAccount: () -> Bool
        let hasMedicalCard: () -> Bool
        let loyaltyModel: (_ completion: @escaping (LoyaltyModel) -> Void) -> Void
        let accountType: () -> AccountType
    }

    struct Output {
        let about: () -> Void
        let logout: () -> Void
        let accountInfo: () -> Void
        let editAccountInfo: () -> Void
		let demo: () -> Void
        let switchAccountType: () -> Void
        let bonus: () -> Void
        let notificationsList: () -> Void
        let loginOptions: () -> Void
        let login: () -> Void
        let designSystem: () -> Void
        let medicalCard: () -> Void
		let switchTheme: () -> Void
		let openBanner: (_ bannerId: Int) -> Void
    }

    struct Notify {
        var accountChanged: (Account?) -> Void
        var accountTypeChanged: () -> Void
        var authorizationStateChanged: (Bool) -> Void
    }

    var input: Input!
    var output: Output!

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        accountChanged: { [weak self] userAccount in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.updateRoundedTopHeader()
            self.updateChangeAccountTypeView()
            
            guard let userAccount = userAccount
            else { return }
            
			self.updateBanners(with: userAccount)
            self.updateAccountHeaderView(with: userAccount)
            self.setVisibleMedicalCardOptionView()
        },
        accountTypeChanged: { [weak self] in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.updateRoundedTopHeader()
            self.updateChangeAccountTypeView()
        },
        authorizationStateChanged: { [weak self] isAuthorized in
            guard let self = self,
                  self.viewIfLoaded?.window != nil // check if controller is on-screen
            else { return }

            self.updateWithAuthorization(isAuthorized)
        }
    )

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var bonusHeaderViewContainer: UIView!
	@IBOutlet private var bannersStackView: UIStackView!
    @IBOutlet private var roundedTopHeaderView: RoundedTopHeaderView!
    @IBOutlet private var changeAccountTypeView: ChangeAccountTypeView!
    @IBOutlet private var settingsMenuStackView: UIStackView!
    @IBOutlet private var accountHeaderViewContainer: UIView!
    @IBOutlet private var unauthorizedContainerView: UIView!
    @IBOutlet private var designSystemOptionView: CardView!
	@IBOutlet private var changeAccountCardView: CardView!
	
	private lazy var accountHeaderView: AccountHeaderView = .fromNib()
    private lazy var bonusHeaderView: BonusHeaderView = .fromNib()
    
    private let medicalCardOptionView = MenuOptionArrowView()
	private let themeCardOptionView = MenuOptionArrowView()
    private let loginOptionsOptionView = MenuOptionArrowView()
    private let aboutAppOptionView = MenuOptionArrowView()
    private let logoutOptionsOptionView = MenuOptionArrowView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        input.account { [weak self] userAccount in
            guard let self = self
            else { return }
            
			self.updateBanners(with: userAccount)
            self.updateAccountHeaderView(with: userAccount)
            self.updateRoundedTopHeader()
            self.updateChangeAccountTypeView()
        }
        
        updateWithAuthorization(input.isAuthorized())
        navigationController?.isNavigationBarHidden = true
    }

    deinit {
        logger?.debug("")
    }

    // MARK: - Setup UI
    private func setup() {
		changeAccountCardView.contentColor = .Background.backgroundSecondary
		designSystemOptionView.backgroundColor = .Background.backgroundSecondary

        view.backgroundColor = .Background.backgroundContent
        
        accountHeaderViewContainer.addSubview(accountHeaderView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: accountHeaderView, in: accountHeaderViewContainer))
        bonusHeaderViewContainer.addSubview(bonusHeaderView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: bonusHeaderView, in: bonusHeaderViewContainer))
        bonusHeaderView.input = .init(
            loyaltyModel: { [weak self] completion in
                guard
                    let self = self,
                    self.input.isAuthorized()
                else { return }

                self.input.loyaltyModel(completion)
            }
        )
        bonusHeaderView.output = .init(
            onTap: { [weak self] in
                self?.output.bonus()
            }
        )

        updateRoundedTopHeader()
        updateChangeAccountTypeView()
		
		themeCardOptionView.configure(
			logoImage: .Icons.theme,
			title: NSLocalizedString("user_profile_application_theme", comment: "")
		) { [weak self] in
			self?.output.switchTheme()
		}
		themeCardOptionView.height(60)
        
        loginOptionsOptionView.configure(
            logoImage: .Icons.settings,
            title: NSLocalizedString("user_profile_login_settings", comment: "")
        ) { [weak self] in
            self?.output.loginOptions()
        }
        loginOptionsOptionView.height(60)

        aboutAppOptionView.configure(
            logoImage: .Icons.phoneInfo,
            title: NSLocalizedString("user_profile_about_app", comment: "")
        ) { [weak self] in
            self?.output.about()
        }
        aboutAppOptionView.height(60)
        
        logoutOptionsOptionView.configure(
            logoImage: .Icons.exit,
			title: input.isDemoAccount()
				? NSLocalizedString("user_profile_logout_demo_app", comment: "")
				: NSLocalizedString("user_profile_logout_app", comment: "")
        ) { [weak self] in
            self?.output.logout()
        }
        logoutOptionsOptionView.height(60)
        
        medicalCardOptionView.configure(
            logoImage: .Icons.medicalCard,
            title: NSLocalizedString("medical_card_menu_item_title", comment: "")
        ) { [weak self] in
            self?.output.medicalCard()
        }
        medicalCardOptionView.height(60)
        setVisibleMedicalCardOptionView()
        
        settingsMenuStackView.addArrangedSubview(medicalCardOptionView)
        settingsMenuStackView.addArrangedSubview(spacer(1, color: .Stroke.divider))
		settingsMenuStackView.addArrangedSubview(themeCardOptionView)
		settingsMenuStackView.addArrangedSubview(spacer(1, color: .Stroke.divider))
        settingsMenuStackView.addArrangedSubview(loginOptionsOptionView)
        settingsMenuStackView.addArrangedSubview(spacer(1, color: .Stroke.divider))
        settingsMenuStackView.addArrangedSubview(aboutAppOptionView)
        settingsMenuStackView.addArrangedSubview(spacer(1, color: .Stroke.divider))
        settingsMenuStackView.addArrangedSubview(logoutOptionsOptionView)
        
        unauthorizedContainerView.backgroundColor = .Background.backgroundContent
        let unauthorizedView: IllustratedNotifyWithButton = .fromNib()
        unauthorizedView.set(
            input: .init(
                text: NSLocalizedString("main_auth_text", comment: ""),
                buttonTitle: NSLocalizedString("auth_sign_in_sign_in", comment: "")
            ),
            action: output.login
        )
        unauthorizedContainerView.addSubview(unauthorizedView)
        unauthorizedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unauthorizedView.leadingAnchor.constraint(equalTo: unauthorizedContainerView.leadingAnchor, constant: Constants.defaultOffset),
            unauthorizedView.trailingAnchor.constraint(
                equalTo: unauthorizedContainerView.trailingAnchor,
                constant: -Constants.defaultOffset
            ),
            unauthorizedView.centerXAnchor.constraint(equalTo: unauthorizedContainerView.centerXAnchor),
            unauthorizedView.centerYAnchor.constraint(equalTo: unauthorizedContainerView.centerYAnchor)
        ])
        unauthorizedContainerView.isHidden = input.isAuthorized()

        // ATTENTION: Don't show design system menu in .prodAdHoc and .appStore!!!

        let canShowDebugMenu = [ .prod, .stage, .test, .stageAdHoc, .testAdHoc ].contains(environment)
        designSystemOptionView.isHidden = !canShowDebugMenu
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openDesignSystemTap))
        designSystemOptionView.addGestureRecognizer(tapGestureRecognizer)
    }
	
	private func updateBanners(with account: Account) {
		bannersStackView.subviews.forEach { $0.removeFromSuperview() }
				
		for bannerIndex in account.profileBanners.indices {
			let banner = account.profileBanners[bannerIndex]
			let profileBannerView = ProfileBannerView()
			
			profileBannerView.set(
				themedTitle: banner.themedTitle,
				themedDescription: banner.themedDescription,
				themedBackgroundColor: banner.themedBackgroundColor,
				themedImage: banner.themedImage,
				themedLink: banner.themedLink,
				amountThemedText: banner.points?.themedAmount,
				amountThemedIcon: banner.points?.themedIcon,
				openURL: { [weak self] in
					guard let self
					else { return }
					
					output.openBanner(bannerIndex)
				}
			)

			bannersStackView.addArrangedSubview(profileBannerView)
		}
	}

    @objc private func openDesignSystemTap() {
        output.designSystem()
    }
    
    private func setVisibleMedicalCardOptionView(){
        medicalCardOptionView.isHidden = !input.hasMedicalCard()
    }

    private func updateWithAuthorization(_ isAuthorized: Bool) {
        unauthorizedContainerView?.isHidden = isAuthorized
        if isAuthorized {
            bonusHeaderView.notify.shouldUpdate()
        } else {
            accountHeaderView.isHidden = true
        }
    }

    private func updateAccountHeaderView(with userAccount: Account) {
        accountHeaderView.isHidden = false
        accountHeaderView.configure(
            userAccount,
            onTap: output.accountInfo,
			onEditTap: output.editAccountInfo, 
			onDemoTap: output.demo
        )
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    private func updateChangeAccountTypeView() {
        changeAccountTypeView.configure(input.accountType()) { [weak self] in
            self?.output.switchAccountType()
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		input.account { [weak self] userAccount in
			guard let self = self
			else { return }
			
			self.updateBanners(with: userAccount)
			self.updateAccountHeaderView(with: userAccount)
			self.updateRoundedTopHeader()
			self.updateChangeAccountTypeView()
		}
	}

    private func updateRoundedTopHeader() {
        switch input.accountType() {
            case .alfaStrah:
                roundedTopHeaderView.title = NSLocalizedString("user_profile_alfa_strah", comment: "")
            case .alfaLife:
                roundedTopHeaderView.title = NSLocalizedString("user_profile_alfa_strah_life", comment: "")
        }
    }
}
