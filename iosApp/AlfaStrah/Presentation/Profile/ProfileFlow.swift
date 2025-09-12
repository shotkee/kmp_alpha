//
//  ProfileFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable file_length
class ProfileFlow: BDUI.ActionHandlerFlow,
				   LoyaltyServiceDependency,
				   MedicalCardServiceDependency,
				   PolicyServiceDependency,
				   UserSessionServiceDependency {
	var loyaltyService: LoyaltyService!
	var medicalCardService: MedicalCardService!
	var policyService: PolicyService!
	var userSessionService: UserSessionService!
	
	let disposeBag: DisposeBag = DisposeBag()
	
    private lazy var accountDataChangedSubscriptions: Subscriptions<AccountData> = Subscriptions()
    private lazy var agreementResetSubscriptions: Subscriptions<Void> = Subscriptions()
    
    struct Notify {
        let accountChange: () -> Void
    }
    
    deinit {
        logger?.debug("")
    }

    private let storyboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
    private var accountSubscriptions: Subscriptions<Account?> = Subscriptions()
	private var accountTypeSubscriptions: Subscriptions<Void> = Subscriptions()
	
	private var nativeProfileViewController: ProfileViewController?
	
    private var accountAuthorized: Bool = false
    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        accountChange: { [weak self] in
            guard let self = self,
                  self.accountService.isAuthorized
            else { return }

            self.accountService.getAccount(useCache: true) { result in
                switch result {
                    case .success(let account):
                        self.accountSubscriptions.fire(account)
                    case .failure:
                        break
                }
            }
        }
    )
    
    private var agreementConfirmed: Bool = false
    private var agreementLinks: PersonalDataUsageAndPrivacyPolicyURLs?
    
    private struct AccountData {
        var firstName: String?
        var lastName: String?
        var patronymic: String?
        var phone: Phone?
        var birthDate: Date?
        var email: String?
        
        var isFilled: Bool {
            let values: [Any?] = [
                firstName,
                lastName,
                phone,
                birthDate,
                email
            ]
            return !values.contains { $0 == nil }
        }
        
        init() {}
        
        init(from account: Account) {
            self.firstName = account.firstName
            self.lastName = account.lastName
            self.patronymic = account.patronymic
            self.phone = account.phone
            self.birthDate = account.birthDate
            self.email = account.email
        }
    }

    private var accountData: AccountData = .init() {
        didSet {
            accountDataChangedSubscriptions.fire(accountData)
        }
    }
    	
    func start() {
		setupInitalController(withNativeRender: false)
        
        initialViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar_profile_title", comment: ""),
            image: .Icons.profile,
            selectedImage: nil
        )
		
		accountService.subscribeForAccountUpdates { account in
			self.nativeProfileViewController?.notify.accountChanged(account)
		}.disposed(by: self.disposeBag)
		
		userSessionService.subscribeSession { userSession in
			let accountAuthorized = userSession != nil
			if accountAuthorized != self.accountAuthorized {
				self.accountAuthorized = accountAuthorized
				self.nativeProfileViewController?.notify.authorizationStateChanged(self.accountAuthorized)
			}
			
			self.setupInitalController(withNativeRender: false)
		}.disposed(by: self.disposeBag)
		
		accountTypeSubscriptions.add{
			self.nativeProfileViewController?.notify.accountTypeChanged()
		}.disposed(by: self.disposeBag)
    }
	
	func setupInitalController(withNativeRender: Bool) {
		if withNativeRender {
			accountAuthorized = accountService.isAuthorized
			nativeProfileViewController = createProfileViewController()
			if let nativeProfileViewController {
				initialViewController.setViewControllers([ nativeProfileViewController ], animated: false)
			}
		} else {
			let hide = initialViewController.showLoadingIndicator(message: nil)
			backendDrivenService.profile { result in
				hide(nil)
				switch result {
					case .success(let data):
						if let screenBackendComponent = BDUI.DataComponentDTO(body: data).screen {
							let profileViewController = BDUI.ViewControllerUtils.createBasicBackendDrivenViewController(
								with: screenBackendComponent,
								use: self.backendDrivenService,
								use: self.analytics,
								isRootController: true,
								tabIndex: 4,
								backendActionSelectorHandler: { events, viewController in
									guard let viewController
									else { return }
									
									self.handleBackendEvents(
										events,
										on: viewController,
										with: screenBackendComponent.screenId,
										isModal: false,
										syncCompletion: nil
									)
								},
								syncCompletion: nil
							)
														
							self.container?.resolve(profileViewController)
							
							self.initialViewController.setViewControllers([ profileViewController ], animated: false)
						}
						
					case .failure:
						self.setupInitalController(withNativeRender: true)
						
				}
			}
		}
	}

    private func createProfileViewController() -> ProfileViewController {
        let viewController: ProfileViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            account: { completion in
                guard self.accountService.isAuthorized
                else { return }
                
                self.accountService.getAccount(useCache: true) { result in
                    switch result {
                        case .success(let userAccount):
                            completion(userAccount)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            },
            isAuthorized: {
                return self.accountService.isAuthorized
            },
			isDemoAccount:
			{
				self.accountService.isDemo
			},
            hasMedicalCard: {
                return self.accountService.hasMedicalFileStorage
            },
            loyaltyModel: { completion in
                guard self.accountAuthorized else { return }

                self.loyaltyService.loyalty(useCache: false) { result in
                    switch result {
                        case .success(let response):
                            completion(response)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            },
            accountType: { self.applicationSettingsService.accountType }
        )

        viewController.output = .init(
            about: showAbout,
            logout: { [weak viewController] in
				guard let viewController
				else { return }
				
				self.showLogout(from: viewController)
            },
            accountInfo: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
				self.showAccountInfo(from: viewController)
            },
            editAccountInfo: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                guard !self.accountService.isDemo else {
                    DemoAlertHelper().showDemoAlert(from: viewController)
                    return
                }
                
                self.showProfileInfoEditViewController(from: viewController)
			},
			demo: { [weak viewController] in
				guard let viewController
				else { return }
				
				DemoBottomSheet.presentInfoDemoSheet(from: viewController)
			},
            switchAccountType: { [weak viewController] in
				guard let viewController
				else { return }
				
				self.changeAccountType(withIndicator: true, from: viewController) {}
            },
            bonus: showBonus,
            notificationsList: showNotificationsList,
            loginOptions: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                guard !self.accountService.isDemo
                else {
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
                    return
                }
                
                self.showSettings()
            },
            login: {
                ApplicationFlow.shared.show(item: .login)
            },
            designSystem: { [weak viewController] in
                guard let viewController = viewController
                else { return }

                let flow = DesignSystemFlow(rootController: viewController)
                self.container?.resolve(flow)
                flow.start()
            },
            medicalCard: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                self.showMedicalCard(from: viewController)
            },
			switchTheme: { [weak viewController] in
				guard let viewController
				else { return }
				
				self.showApplicationTheme(from: viewController)
			},
			openBanner: { [weak viewController] bannerId in
				guard let viewController
				else { return }
				let webViewController = WebViewController()
				
				webViewController.input = .init(
					url: { completion in
						self.accountService.getAccount(useCache: false) { result in
							switch result {
								case .success(let account):
									if let foundBanner = account.profileBanners[safe: bannerId],
									   let url = foundBanner.themedLink?.url {
										completion(.success(url))
									} else {
										completion(.failure(.unknownError))
									}
								case .failure(let error):
									completion(.failure(error))
							}
						}
					},
					requestAuthorizationIsNeeded: false,
					showShareButton: true,
					needSharedUrl: true,
					urlShareable: nil,
					cookiesDidChange: nil,
					cookiePartUrlDetectStringCondition: nil,
					headers: nil
				)
								
				webViewController.output = .init(
					toChat: { [weak webViewController] in
						guard let webViewController
						else { return }

						let chatFlow = ChatFlow()
						self.container?.resolve(chatFlow)
						chatFlow.show(from: webViewController, mode: .fullscreen)
					}, 
					toFile:
					{
						[weak webViewController] in
						
						guard let webViewController
						else { return }
						
						WebViewer.openDocument(
							$0,
							needSharedUrl: true,
							from: webViewController
						)
					},
					close: { [weak viewController] in
						viewController?.dismiss(
							animated: true
						)
					}
				)
				
				viewController.present(
					UINavigationController(rootViewController: webViewController),
					animated: true
				)
				
			}
        )
		
        return viewController
    }
	
	func showApplicationTheme(from viewController: UIViewController) {
		let viewController = ApplicationThemeSwitchViewController()

		viewController.input = .init(
			currentTheme: {
				return applicationSettingsService.themeWasApplied == .yes
					? applicationSettingsService.applicationTheme
					: .light
			}()
		)
		viewController.output = .init(
			selected: { theme in
				self.applicationSettingsService.applicationTheme = theme
				self.applicationSettingsService.themeWasApplied = .yes
				
				if #available(iOS 13.0, *) {
					ApplicationFlow.shared.apply(applicationTheme: theme)
				}
			}
		)
		
		pushInNavigationController(viewController)
	}
    
	func showSettings() {
        let viewController: SecuritySettingsViewController = self.storyboard.instantiate()
        self.container?.resolve(viewController)
        
        viewController.output = .init(
            saveNewPassword: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                self.showCurrentPasswordController(from: viewController)
            }
        )

        pushInNavigationController(viewController)
    }

    private func showCurrentPasswordController(from: ViewController) {
        guard let currentPassword = applicationSettingsService.password
        else { return }
        
        let viewController = CurrentPasswordViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            currentPassword: currentPassword
        )
        
        viewController.output = .init(
            toNewPassword: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                let hide = from.showLoadingIndicator(message: nil)
                
                self.accountService.getAccount(useCache: true) { [weak self] result in
                    
                    hide(nil)
                    
                    guard let self = self
                    else { return }
                    
                    switch result {
                        case .success(let account):
                            self.startAuthFlowAndCreateNewPasswordController(
                                for: account.id,
                                with: currentPassword,
                                from: viewController
                            )

                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            },
            forgotPassword: {
                self.showForgotPassword()
            }
        )
        
        pushInNavigationController(viewController)
    }
    
    private func showLogOutAlertIfLoadingMedicalCardFiles(
        from viewController: UIViewController
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString("common_attention", comment: ""),
            message: NSLocalizedString("main_unload_medical_card_files", comment: ""),
            preferredStyle: .alert
        )
        let presentMedicalCardFileAction = UIAlertAction(
            title: NSLocalizedString("main_present_medical_card_files", comment: ""),
            style: .default
        ) { [weak viewController] _ in
                guard let viewController = viewController
                else { return }
                self.showMedicalCard(from: viewController)
        }
        let logOutAction = UIAlertAction(
            title: NSLocalizedString("common_whatever_quit", comment: ""),
            style: .default
        ) { _ in
            ApplicationFlow.shared.show(item: .logout)
        }
        let stayAction = UIAlertAction(
            title: NSLocalizedString("common_stay_button", comment: ""),
            style: .cancel
        )
        alert.addAction(presentMedicalCardFileAction)
        alert.addAction(logOutAction)
        alert.addAction(stayAction)
        viewController.present(alert, animated: true)
    }
    
    private func showLogOutAlert(
        from viewController: UIViewController,
		logout: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString("main_menu_logout", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: NSLocalizedString("common_quit", comment: ""), style: .destructive) { _ in
            ApplicationFlow.shared.show(item: .logout)
			logout()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true)
    }
    
    private func showMedicalCard(from: UIViewController) {
        let medicalCardFlow = MedicalCardFlow(rootController: from)
        self.container?.resolve(medicalCardFlow)
        medicalCardFlow.start()
    }
    
    private func showProfileInfoEditViewController(from viewController: UIViewController) {
        var currentAccount: Account?
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        accountService.getAccount(useCache: true) { result in
            dispatchGroup.leave()
            switch result {
                case .success(let account):
                    self.accountData = AccountData(from: account)
                    currentAccount = account
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }

        dispatchGroup.enter()
        policyService.getPersonalDataUsageTermsUrl(on: .signUp) { result in
            dispatchGroup.leave()
            switch result {
                case.success(let links):
                    self.agreementLinks = links
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
        
        dispatchGroup.notify(queue: .main) {            
            guard let currentAccount = currentAccount
            else { return }
            
            let profileInfoEditViewController = self.createProfileInfoEditViewController(
                for: currentAccount,
                withTerms: self.agreementLinks
            )
                        
            self.presentInNavigationController(profileInfoEditViewController)
        }
    }

    private func createNewAccountForUpdate(from currentAccount: Account) -> Account? {
        guard let firstName = accountData.firstName,
              let lastName = accountData.lastName,
              let phone = accountData.phone,
              let birthDate = accountData.birthDate,
              let email = accountData.email
        else { return nil }
        
        return Account(
            id: currentAccount.id,
            firstName: firstName,
            lastName: lastName,
            patronymic: accountData.patronymic,
            phone: phone,
            birthDate: birthDate,
            email: email,
            unconfirmedPhone: currentAccount.unconfirmedPhone,
            unconfirmedEmail: currentAccount.unconfirmedEmail,
            isDemo: currentAccount.isDemo,
            additions: currentAccount.additions,
			profileBanners: currentAccount.profileBanners
        )
    }
        
    private func createProfileInfoEditViewController(
        for currentAccount: Account,
        withTerms links: PersonalDataUsageAndPrivacyPolicyURLs?
    ) -> ProfileInfoEditViewController {
        let viewController = ProfileInfoEditViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            accountData: {
                return ProfileInfoEditViewController.AccountData(
                    firstName: self.accountData.firstName ?? "",
                    lastName: self.accountData.lastName ?? "",
                    patronymic: self.accountData.patronymic,
                    phone: self.accountData.phone,
                    birthDate: self.accountData.birthDate ?? Date(),
                    email: self.accountData.email
                )
            },
            agreementLinks: agreementLinks
        )
        
        viewController.output = .init(
            save: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                guard let newAccount = self.createNewAccountForUpdate(from: currentAccount)
                else {
                    self.alertPresenter.show(alert: ErrorNotificationAlert(
                        error: nil,
                        text: NSLocalizedString("edit_profile_info_incorrectly_filled_data_for_account_update", comment: ""))
                    )
                    return
                }
                
                guard currentAccount != newAccount
                else { return }
                
                func proceedConfirmation(with otpVerificationResendTimeInterval: TimeInterval) {
                    self.accountService.getAccount(useCache: false) { result  in
                        switch result {
                            case .success(let account):
                                if let unconfirmedPhone = account.unconfirmedPhone,
                                   newAccount.phone != account.phone {
                                    self.showConfirmPhone(
                                        unconfirmedPhone,
                                        otpVerificationResendTimeInterval: otpVerificationResendTimeInterval,
                                        from: viewController
                                    ) {
                                        if let unconfirmedEmail = account.unconfirmedEmail {
                                            self.displayEmailConfirmationAlert(for: unconfirmedEmail, from: viewController)
                                        }
                                    }
                                } else if let unconfirmedEmail = account.unconfirmedEmail,
                                          newAccount.email != account.email {
                                    self.displayEmailConfirmationAlert(for: unconfirmedEmail, from: viewController)
                                }
                            case .failure(let error):
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                        }
                    }
                }
                
                if SmsCodeViewController.resendTimerDuration <= 0 {
                    let hide = viewController.showLoadingIndicator(
                        message: NSLocalizedString("common_loading_title", comment: "")
                    )
                    self.accountService.updateAccount(currentAccount, newAccountData: newAccount) { result in
                        hide(nil)
                        switch result {
                            case .success(let updateAccountResponse):
                                proceedConfirmation(with: updateAccountResponse.otpVerificationResendTimeInterval)
                            case .failure(let error):
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                        }
                    }
                } else {
                    proceedConfirmation(with: SmsCodeViewController.resendTimerDuration)
                }
            },
            showDocument: { url in
                WebViewer.openDocument(url, from: viewController)
            },
            updateAgreementState: { [weak viewController] checked in
                self.agreementConfirmed = checked
                
				viewController?.notify.isSaveButtonEnabled(self.accountCanBeSaved(with: currentAccount))
            },
            toChat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            emailEntered: { email in
                self.accountData.email = email
            },
            phoneEntered: { phone in
                self.accountData.phone = phone
			}
        )
        
        accountDataChangedSubscriptions
            .add { [weak viewController] _ in
                viewController?.notify.updateSections(
                    ProfileInfoEditViewController.AccountData(
                        firstName: self.accountData.firstName ?? "",
                        lastName: self.accountData.lastName ?? "",
                        patronymic: self.accountData.patronymic,
                        phone: self.accountData.phone,
                        birthDate: self.accountData.birthDate ?? Date(),
                        email: self.accountData.email
                    )
                )
            }
            .disposed(by: viewController.disposeBag)
        
        agreementResetSubscriptions
            .add { [weak viewController] in
                viewController?.notify.resetAgreementState()
            }
            .disposed(by: viewController.disposeBag)
        
        return viewController
    }
    
	private func accountCanBeSaved(with account: Account) -> Bool {
		guard let enteredPhone = accountData.phone?.plain,
			  let enteredEmail = accountData.email
		else { return false }
		
		let currentPhone = account.phone.plain
		let currentEmail = account.email
		let fieldsEdited = currentPhone != enteredPhone || currentEmail != enteredEmail
        return fieldsEdited && agreementConfirmed
    }
    
    private func switchSession(completion: @escaping () -> Void) {
        guard accountService.isAuthorized
        else { return }
        
        guard let controller = initialViewController.topViewController as? ViewController
        else { return }
        		
        ApplicationFlow.shared.switchSession(to: self.applicationSettingsService.userTypeForSwitch) { result in
            switch result {
                case .success:
					completion()
                case .failure(let error):
					completion()
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func showBonus() {
        guard let topVC = initialViewController.topViewController else { return }

        let flow = LoyaltyFlow()
        container?.resolve(flow)
        flow.startModally(from: topVC)
    }
    
    private func getPersonalDataUsageTermsUrl(
        from: ViewController,
        completion: @escaping (PersonalDataUsageAndPrivacyPolicyURLs) -> Void
    ) {
        let hide = from.showLoadingIndicator(message: nil)

        policyService.getPersonalDataUsageTermsUrl(on: .aboutApp) { result in
            hide(nil)
            switch result {
                case.success(let links):
                    completion(links)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    func showAbout() {
        let storyboard = UIStoryboard(name: "About", bundle: nil)
        let controller: AboutAppViewController = storyboard.instantiate()

        pushInNavigationController(controller)
        
        controller.input = .init(
            getPersonalDataUsageTermsUrls: { [weak controller] completion in
                guard let controller = controller
                else { return }

                self.getPersonalDataUsageTermsUrl(from: controller, completion: completion)
            }
        )
        controller.output = .init(
            openAppStore: { [weak self ] completion in
				self?.userSessionService.getAppStoreLink { result in
                    completion(result)
                    if case .success(let response) = result {
                        let rateUrlString = response + "?action=write-review"
                        let url = URL(string: rateUrlString)
                        guard let url = url else { return }

                        UIApplication.shared.open(url, options: [:]) { _ in }
                    }
                }
            },
            openIntroductionView: {
                let viewController = OnboardingViewController()
                self.container?.resolve(viewController)

                viewController.output = .init(
                    onComplete: {
                        self.initialViewController.dismiss(animated: false)
                    }
                )

                self.presentInNavigationController(viewController)
            },
            linkTap: { [weak controller] url in
                guard let controller = controller else { return }

                SafariViewController.open(url, from: controller)
            }
        )
    }

    private func showNotificationsList() {
        guard accountService.isAuthorized
        else { return }
        
        guard let fromVC = initialViewController.topViewController as? ViewController
        else { return }
        
        guard !accountService.isDemo
        else {
            DemoAlertHelper().showDemoAlert(from: fromVC)
            return
        }

        let notificationsFlow = NotificationsFlow(rootController: fromVC)
        self.container?.resolve(notificationsFlow)
        
        notificationsFlow.showList(mode: .modal)
    }
    
    private func showForgotPassword() {
        guard let oldPassword = applicationSettingsService.password
        else { return }
        
        let viewController = ForgottenPasswordViewController()
        container?.resolve(viewController)
        
        viewController.output = .init(
            resetPassword: { phone, email in
                let hide = viewController.showLoadingIndicator(message: nil)
                self.accountService.resetPassword(email: email, phone: phone) { [weak viewController] result in
                    guard let viewController = viewController
                    else { return }
                    
                    hide(nil)
                    switch result {
                        case .success(let response):
                            self.startAuthFlowAndCreateNewPasswordController(for: response.accountId, with: oldPassword, from: viewController)
                        case .failure(let error):
                            if let errorMessage = error.message {
                                viewController.notify.showError(errorMessage)
                            } else {
                                viewController.notify.showError(
                                    NSLocalizedString("forgotten_password_common_error_description", comment: "")
                                )
                            }
                    }
                }
            },
            toChat: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                self.openChatModally(from: viewController)
            },
            close: { [weak viewController] in
                viewController?.navigationController?.popViewController(animated: true)
            }
        )
        
        pushInNavigationController(viewController)
    }

	private func startAuthFlowAndCreateNewPasswordController(for accountId: String, with oldPassword: String, from: ViewController) {
		let authFlow = AuthorizationFlow(rootController: UIHelper.findTopModal(controller: from))
		container?.resolve(authFlow)

		authFlow.showCreateNewPassword(for: accountId, with: oldPassword)
	}

    private func showConfirmPhone(
        _ phone: Phone,
        otpVerificationResendTimeInterval: TimeInterval,
        from: UIViewController,
        _ completion: (() -> Void)? = nil
    ) {
        let viewController = SmsCodeViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            phoneDisplayString: phone.humanReadable,
            isMaskedPhoneNumber: false,
            resendSmsCodeTimer: otpVerificationResendTimeInterval
        )
        viewController.output = .init(
            verify: { [weak self] code in
                self?.accountService.verifyPhone(code: code) { [weak viewController, weak from]  result in
                    guard let viewController = viewController
                    else { return }

                    switch result {
                        case .success:
                            from?.navigationController?.popToRootViewController(animated: true)
                            self?.getAccount()
                            completion?()
                        case .failure(let error):
                            switch error {
                                case .api(let apiError):
                                    switch apiError.internalCode {
                                        case OtpConfirmInternalCode.attemptsLeft.rawValue:
                                            viewController.notify.otpVerificationFailed(
                                                apiError.message
                                            )
                                        case OtpConfirmInternalCode.attemptsLimitExceeded.rawValue, OtpConfirmInternalCode.invalid.rawValue:
                                            self?.showApiErrorAlert(
                                                with: apiError,
                                                from: viewController
                                            )
                                            viewController.notify.otpVerificationFailed("")
                                        default:
                                            viewController.notify.otpVerificationFailed("")
                                            ErrorHelper.show(error: error, alertPresenter: viewController.alertPresenter)
                                    }
								case .network, .error, .infoMessage:
                                    viewController.notify.otpVerificationFailed("")
                                    ErrorHelper.show(error: error, alertPresenter: viewController.alertPresenter)
                            }
                    }
                }
            },
            resendSms: { [weak self] in
                self?.accountService.resendPhoneVerificationCode { [weak viewController] result in
                    guard let viewController = viewController
                    else { return }

                    switch result {
                        case .success:
                            break
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: viewController.alertPresenter)
                    }
                }
            },
            openChat: { [weak viewController] in
                guard let viewController = viewController
                else { return }

                self.openChatModally(from: viewController)
            }
        )
        
        viewController.addBackButton { [weak viewController] in
            viewController?.navigationController?.popViewController(animated: true)
            completion?()
        }

        from.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showApiErrorAlert(
         with error: APIError,
         from: ViewController
     ) {
         let alert = UIAlertController(
             title: error.title,
             message: error.message,
             preferredStyle: .alert
         )
         
         let confirmAction = UIAlertAction(
            title: NSLocalizedString(
                "auth_sign_up_alert_confirm_button_title",
                comment: ""
            ),
            style: .default,
            handler: nil
         )
         
         alert.addAction(confirmAction)
         
         from.present(
             alert,
             animated: true
         )
     }

    private func openChatModally(from: ViewController) {
        let chatFlow = ChatFlow()
        container?.resolve(chatFlow)
        chatFlow.show(from: from, mode: .sheet)
    }

    private func resendConfirmationEmail() {
        accountService.resendVerificationEmail { result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func getAccount(_ completion: ((Account) -> Void)? = nil) {
        guard accountService.isAuthorized
        else { return }
        
        accountService.getAccount(useCache: true) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let account):
                    completion?(account)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    // MARK: - Helpers

    private func presentInNavigationController(_ viewController: ViewController) {
        let navController = RMRNavigationController(rootViewController: viewController)
        navController.strongDelegate = RMRNavigationControllerDelegate()
        viewController.addCloseButton { [weak viewController] in
            viewController?.presentingViewController?.dismiss(animated: true)
        }
        initialViewController.topViewController?.present(navController, animated: true)
    }
    
    private func pushInNavigationController(_ viewController: ViewController) {
        initialViewController.setNavigationBarHidden(false, animated: true)
        viewController.addBackButton {
            self.initialViewController.popViewController(animated: true)
        }
        viewController.hidesBottomBarWhenPushed = true
        initialViewController.pushViewController(viewController, animated: true)
    }

    private func displayEmailConfirmationAlert(for email: String, from: UIViewController) {
        let title = NSLocalizedString("user_profile_change_email", comment: "")
        let message = String(format: NSLocalizedString("user_profile_change_email_message", comment: ""), email)
        let resend = NSLocalizedString("user_profile_resend", comment: "")
        let cancel = NSLocalizedString("common_cancel_button", comment: "")

        let ctrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let resendAction = UIAlertAction(title: resend, style: .destructive) { [weak self] _ in
            self?.resendConfirmationEmail()
            self?.agreementResetSubscriptions.fire(())
        }

        let cancelAction = UIAlertAction(title: cancel, style: .cancel) { [weak self] _ in
            self?.agreementResetSubscriptions.fire(())
        }

        let actions: [UIAlertAction] = [ resendAction, cancelAction ]
        actions.forEach { ctrl.addAction($0) }
        from.present(ctrl, animated: true, completion: nil)
    }
	
	func showLogout(from: ViewController, completion: (() -> Void)? = nil) {
		if self.accountService.isDemo
		{
			DemoBottomSheet.presentLogOutDemoSheet(
				from: from
			)
		}
		else
		{
			if self.medicalCardService.haveUploadingFiles() {
				self.showLogOutAlertIfLoadingMedicalCardFiles(
					from: from
				)
			} else {
				self.showLogOutAlert(from: from) {
					completion?()
				}
			}
		}
	}
	
	func showAccountInfo(from: ViewController) {
		guard !self.accountService.isDemo else {
			DemoBottomSheet.presentInfoDemoSheet(from: from)
			return
		}
		
		self.showProfileInfoEditViewController(from: from)
	}
	
	func changeAccountType(withIndicator: Bool, from viewController: ViewController, _ completion: @escaping () -> Void) {
		if self.accountService.isDemo {
			DemoBottomSheet.presentInfoDemoSheet(from: viewController)
		} else {
			var hide: (((() -> Void)?) -> Void)?
			
			if withIndicator {
				hide = viewController.showLoadingIndicator(message: NSLocalizedString("insurance_switch_session_title", comment: ""))
			}

			self.switchSession {
				self.accountTypeSubscriptions.fire(())
				
				hide?(nil)
				completion()
			}
		}
	}
}
// swiftlint:enable file_length
