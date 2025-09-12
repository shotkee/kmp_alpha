//
//  AuthorizationFlow.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 01/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import WebKit
import TinyConstraints

// swiftlint:disable file_length

class AuthorizationFlow: BaseFlow,
                         AccountServiceDependency,
                         ApplicationSettingsServiceDependency,
                         SessionServiceDependency,
                         MobileDeviceTokenServiceDependency,
                         ServiceDataManagerDependency,
                         PolicyServiceDependency,
                         BiometricsAuthServiceDependecy,
                         EsiaServiceDependency {
    var policyService: PolicyService!
    var applicationSettingsService: ApplicationSettingsService!
    var accountService: AccountService!
    var sessionService: UserSessionService!
    var biometricsAuthService: BiometricsAuthService!
    var serviceDataManager: ServiceDataManager!
    var mobileDeviceTokenService: MobileDeviceTokenService!
    var esiaService: EsiaService!
    
    private var chatFlow: ChatFlow?

    private(set) var initialAuthFinished: Bool = false
    private let storyboard = UIStoryboard(name: "Auth", bundle: nil)
    private var account: Account? {
        didSet {
            guard let account = account else { return }

            accountId = account.id
        }
    }
    private var accountId: String?
    private var flowCompletionHandler: (() -> Void)?
    
    enum SignInInitialAuthType {
        case noAuth
        case pinCode
        case biometricError
        case biometricCanceled
    }

    func start(completion: @escaping () -> Void) {
        initialAuthFinished = false
        flowCompletionHandler = completion
		isDemoMode = accountService.isDemo

        localServicesUpdate()
        
        // force update
        updateAppAvailability { appAvailable in
            if appAvailable.status != .fullyAvailable {
                let updateAppViewController = self.createUpdateAppViewController(appAvailable)
                self.createAndShowNavigationController(
                    viewController: updateAppViewController,
                    mode: .modal,
                    asInitial: true
                )
            }
        }

        if let initialController = initialController() {
            createAndShowNavigationController(
                viewController: initialController,
                mode: .modal,
                asInitial: true
            )
        } else {
            self.close {
                self.flowCompletionHandler?()
            }
        }
    }

    func switchSession(to userType: AccountType, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        sessionService.switchSession(accountType: userType) { result in
            switch result {
                case .success(let bool):
                    self.serviceDataManager.erase(logout: false)
                    self.localServicesUpdate()

                    completion(.success(bool))
                    
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func showWelcomeController() {
        createAndShowNavigationController(viewController: welcomeController(), mode: .modal, asInitial: true)
    }
	
	func showLogInViewController(hasRootVC: Bool)
	{
		if !hasRootVC
		{
			createAndShowNavigationController(
				viewController: welcomeController(),
				mode: .modal,
				asInitial: true
			)
		}
		
		createAndShowNavigationController(
			viewController: self.signIn(initialAuthType: .noAuth),
			mode: .push,
			animated: false
		)
	}
    
    func showPincode() {
        createAndShowNavigationController(viewController: createEnterPincodeViewController(), mode: .modal, asInitial: true)
    }
    
    let disposeBag: DisposeBag = DisposeBag()
    lazy private(set) var authFromOldAppListener: () -> Void = { [weak self] in
        self?.showAuthMethod()
    }

    private func initialController() -> UIViewController? {
        if !applicationSettingsService.wasOndoarding {
            applicationSettingsService.wasOndoarding = true
            return introductionController()
        }

        switch applicationSettingsService.userAuthType {
            case .notDefined:
                if !self.applicationSettingsService.wasAutorized {
                    return welcomeController()
                } else {
                    return nil
                }
            case .demo:
                return nil
            case .auto:
                return createSetPincodeController()
            case .pin, .biometric:
                if applicationSettingsService.pin != nil {
                    return createEnterPincodeViewController()
                } else {
                    return createSetPincodeController()
                }
            case .full:
                return signIn(initialAuthType: .noAuth)
        }
    }
    
    private func updateAppAvailability(completion: ((AppAvailable) -> Void)?) {
        mobileDeviceTokenService.getDeviceToken { result in
            switch result {
                case .success(let deviceToken):
                    self.sendDeviceData(deviceToken: deviceToken) { appAvailable in
                        completion?(appAvailable)
                    }

                case .failure(let error):
                    self.logger?.error(error.displayValue ?? "Couldn't get device token")
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func sendDeviceData(deviceToken: String, completion: ((AppAvailable) -> Void)?) {
        sessionService.sendDeviceData(deviceToken: deviceToken) { result in
            switch result {
                case .success(let appAvailable):
                    completion?(appAvailable)
                case .failure(let error):
                    self.logger?.error(error.displayValue ?? "Error while update app availability")
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
    
    private func localServicesUpdate(completion: (() -> Void)? = nil) {
        serviceDataManager.update(
            progressHandler: { _ in },
            completion: {
                completion?()
            }
        )
    }

    private func introductionController() -> UIViewController {
        let viewController = OnboardingViewController()
        container?.resolve(viewController)

        func completeOnboarding() {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.createAndShowNavigationController(
				viewController: self.initialController(),
				mode: .push,
				showBackButton: false,
				asInitial: true
			)
        }
        
        viewController.output = .init(
            onComplete: {
                completeOnboarding()
            }
        )
        
        return viewController
    }
    
    private func createEnterPincodeViewController() -> UIViewController {
		/// since we have to hide chat  score request view by enter pin code
		applicationSettingsService.pinCodeScreenWasShownAfterChatScoreRequest = true
		
        let viewController = EnterPincodeViewController()
        container?.resolve(viewController)
		
        viewController.input = .init(
            userAuthType: self.applicationSettingsService.userAuthType,
            code: self.applicationSettingsService.pin,
			numberOfAttempts: self.applicationSettingsService.loginAttempts
        )
        
        viewController.output = .init(
            codeEntered: { result in
                switch result {
                    case .success:
						self.applicationSettingsService.loginAttempts = 0
                        self.updateServicesAndClose()
                        self.startInactivityTimer()
                    case .failure:
						self.applicationSettingsService.loginAttempts += 1
						viewController.notify.update(self.applicationSettingsService.loginAttempts)
                }
            },
            close: {
                self.presentPincodeLogoutAlert{
                    self.serviceDataManager.erase(logout: true)
                    self.stopInactivityTimer()
                    self.updateServicesAndClose()
                }
            },
			attemptsExhausted: {
				self.serviceDataManager.erase(logout: true)
				self.stopInactivityTimer()
				self.updateServicesAndClose {
					self.initialAuthFinished = false
					// show again welcome screen
					self.navigationController?.viewControllers = [] // fix reset topViewController field for createAndShowNavigationController
					self.showWelcomeController()
				}
			},
            biometricAuthenticated: { result in
                switch result {
                    case .success:
						self.applicationSettingsService.loginAttempts = 0
                        self.updateServicesAndClose()
                        self.startInactivityTimer()
                    case .failure:
                        break
                }
            }
        )
        
        return viewController
    }
    
    private func presentPincodeLogoutAlert(_ completion: @escaping () -> Void) {
        guard let viewController = UIHelper.topViewController()
        else { return }
        
        let alert = UIAlertController(
            title: NSLocalizedString("auth_pincode_logout_alert_title", comment: ""),
            message: NSLocalizedString("auth_pincode_logout_alert_description", comment: ""),
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("common_cancel_button", comment: ""),
            style: .cancel
        )
        alert.addAction(cancelAction)
        
        let continueAction = UIAlertAction(
            title: NSLocalizedString("common_quit", comment: ""),
            style: .default,
            handler: { _ in
                completion()
            }
        )
        alert.addAction(continueAction)

        viewController.present(alert, animated: true)
    }
    
	func createSetPincodeController(changePinCode: Bool = false, completion: (() -> Void)? = nil) -> UIViewController {
        let viewController = CreatePincodeViewController()
        container?.resolve(viewController)
                
        viewController.input = .init(
            showExitButton: !changePinCode
        )
        
        viewController.output = .init(
            close: { [weak viewController] in
                self.presentPincodeLogoutAlert{ [weak viewController] in
                    guard let viewController = viewController
                    else { return }
                    
                    // config for initial controller selection
                    self.applicationSettingsService.userAuthType = .notDefined
                    self.applicationSettingsService.wasAutorized = false
                    
                    // reset .fullAuth person cache
                    self.serviceDataManager.erase(logout: true)
                    
                    self.updateServicesAndClose {
                        self.initialAuthFinished = false
                        // show again welcome screen
                        self.navigationController?.viewControllers = [] // fix reset topViewController field for createAndShowNavigationController
                        self.showWelcomeController()
                    }
                }
            },
            codeConfirmed: { [weak viewController] code in
                
                guard let viewController = viewController
                else { return }
                
                self.applicationSettingsService.pin = code
                
                if changePinCode {
                    viewController.navigationController?.popViewController(animated: true)
					completion?()
                } else {
                    self.applicationSettingsService.userAuthType = .pin
                    self.applicationSettingsService.wasAutorized = true
                    
                    self.startInactivityTimer()
                    
                    if self.biometricsAuthService.available {
                        self.presentOfferBiometricAuthenticationController(from: viewController, completion: completion)
                    } else {
                        self.updateServicesAndClose()
						completion?()
                    }
                }
            }
        )
        
        return viewController
    }
    
	private func presentOfferBiometricAuthenticationController(from: ViewController, completion: (() -> Void)? = nil) {
        let viewController = OfferBiometricAuthenticationController()
        container?.resolve(viewController)
        
        viewController.input = .init()
        
        func biometricOfferCompleted() {
            self.applicationSettingsService.userAuthType = .pin
            self.updateServicesAndClose()
        }
        
        viewController.output = .init(
            enable: { [weak viewController] result in
                viewController?.dismiss(animated: true)
                switch result {
                    case .success:
                        self.updateServicesAndClose()
						self.applicationSettingsService.userAuthType = .biometric
                    case .failure:
                        self.updateServicesAndClose()
                }
				completion?()
            },
            close: { [weak viewController] in
                viewController?.dismiss(animated: true)
                biometricOfferCompleted()
				completion?()
            },
            dismissed: {
                biometricOfferCompleted()
				completion?()
            }
        )
        
        let navigationController = RMRNavigationController(rootViewController: viewController)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        from.present(navigationController, animated: true, with: .formSheet)
    }

    private func welcomeController() -> UIViewController {
        let viewController = WelcomeViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            appear: { [weak viewController] in
                self.esiaService.features { result in
                    switch result {
                        case .success(let featuresDictionary):
                            if let esiaEnabled = featuresDictionary["gosuslugi_auth"] as? Bool,
                               esiaEnabled == false {
                                viewController?.notify.showEsiaSignInButton(false)
                            }
                        case .failure:
                            break
                    }
                }
            }
        )
        
        viewController.output = .init(
            showMain: {
                self.updateServicesAndClose()
            },
            showActivateInsurance: { [weak viewController] in
                guard let viewController = viewController else { return }

                self.showActivateInsurance(fromVC: viewController)
            },
            showSignIn: {
                self.createAndShowNavigationController(
                    viewController: self.signIn(initialAuthType: .noAuth),
                    mode: .push
                )
            },
            showRegistration: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                self.showRegistration(from: viewController)
            },
            startDemoMode: { [weak viewController] in
                guard let viewController = viewController
				else { return }
				
				DemoBottomSheet.presentLogInDemoSheet(
					from: viewController,
					action: { [weak viewController] in
						
						viewController?.dismiss(
							animated: true,
							completion: { [weak viewController] in
								guard let viewController
								else { return }
								isDemoMode = true
								self.startDemoMode(viewController: viewController)
							}
						)
					}
				)
            },
            chat: {
                ApplicationFlow.shared.switchTab(to: .chat)
                self.updateServicesAndClose()
            },
            buyInsurance: { [weak viewController] in
                guard let viewController = viewController else { return }

                let flow = InsurancesBuyFlow()
                self.container?.resolve(flow)
                flow.start(from: viewController)
            },
			showEsiaSignIn: { [weak viewController] in
				self.showEsiaSignIn(
					viewController: viewController
				)
			}
        )
        return viewController
    }
	
	private func showEsiaSignIn(viewController: ViewController?)
	{
		self.sessionService.removeCookies()
		self.esiaSessionRequestInProggress = false
		
		let hide = viewController?.showLoadingIndicator(
			message: NSLocalizedString("common_load", comment: "")
		)
		
		self.esiaService.redirect { [weak viewController] result in
			hide?(nil)
			
			guard let viewController
			else { return }
			
			switch result {
				case .success(let response):
					let webViewController = WebViewer.openDocument(
						response.redirectUrl,
						from: viewController,
						cookiesDidChange: { storage in
							self.handleCookies(
								storage,
								with: response.esiaTokenCookieFieldName
							) { [weak viewController] in
								viewController?.dismiss(animated: true) {
									self.createAndShowNavigationController(
										viewController: self.createSetPincodeController(),
										mode: .push
									)
								}
							}
						},
						cookiePartUrlDetectStringCondition: response.regexp
					) {
						self.esiaSessionRequestInProggress = false
					}
				case .failure(let error):
					ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
			}
		}
	}
    
    private var esiaSessionRequestInProggress = false
    private var previousEsiaSession: UserSession?
    
    private func handleCookies(_ storage: WKHTTPCookieStore, with name: String, completion: @escaping () -> Void) {
        func handleEsiaSession(_ session: UserSession?) {
            guard let session,
                  previousEsiaSession != session
            else { return }
            
            previousEsiaSession = session
            
            sessionService.update(with: session)
            
            applicationSettingsService.wasAutorized = true
            
            esiaSessionRequestInProggress = false
            completion()
        }
                
        guard !esiaService.sessionRequestInProggress && !esiaSessionRequestInProggress
        else { return }
        
        if esiaService.sessionWasReceived {
            handleEsiaSession(esiaService.session)
        }
                
        storage.getAllCookies{ cookies in
            guard let cookie = cookies.first(where: { $0.name == name })
            else { return }
            
            if !self.esiaSessionRequestInProggress {
                self.esiaSessionRequestInProggress = true
                self.mobileDeviceTokenService.getDeviceToken { result in
                    switch result {
                        case .success(let deviceToken):
                            self.esiaService.auth(esiaToken: cookie.value, deviceToken: deviceToken) { result in
                                self.esiaSessionRequestInProggress = false
                                switch result {
                                    case .success(let authData):
                                        handleEsiaSession(authData.session)
                                        
                                    case .failure(let error):
                                        ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                                        
                                }
                            }
                            
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                            
                    }
                }
            }
        }
    }
    
    private var agreementLinks: PersonalDataUsageAndPrivacyPolicyURLs?
    
    enum SignUpErrorInternalCode: Int {
        case agimaError = 0
    }
    
    enum SignInErrorInternalCode: Int {
        case agimaError = 0
        case attemptsLeft = 13
        case attemptsLimitExceeded = 14
    }
    
    // swiftlint:disable:next function_body_length
    private func showRegistration(from: ViewController) {
        func updateRegisterTerms(on viewController: SignUpViewController) {
            viewController.notify.update(.loading(title: NSLocalizedString("auth_sign_up_terms_loading_title", comment: "")))
            policyService.registerTerms { [weak viewController] result in
                guard let viewController = viewController
                else { return }
                
                switch result {
                    case .success(let terms):
                        viewController.notify.update(.data(terms))
                    case .failure:
                        viewController.notify.update(.failure(
                            title: NSLocalizedString("auth_sign_up_request_common_error_title", comment: ""),
                            description: NSLocalizedString("auth_sign_up_common_error_description", comment: "")
                        ))
                }
            }
        }
        
        let viewController = SignUpViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            updateTerms: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                updateRegisterTerms(on: viewController)
            }
        )
        
        viewController.output = .init(
            appear: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                updateRegisterTerms(on: viewController)
            },
            signUp: { [weak viewController] registrationUserPersonalInfo in
                guard let viewController = viewController
                else { return }
                
                viewController.notify.update(.loading(title: NSLocalizedString("auth_sign_up_data_loading_title", comment: "")))
                
                if let firstname = registrationUserPersonalInfo.firstname,
                   let lastname = registrationUserPersonalInfo.lastname,
                   let phone = registrationUserPersonalInfo.phone,
                   let birthDate = registrationUserPersonalInfo.birthDate,
                   let email = registrationUserPersonalInfo.email {
                    let account = Account(
                        id: "",
                        firstName: firstname,
                        lastName: lastname,
                        patronymic: registrationUserPersonalInfo.patronymic,
                        phone: phone,
                        birthDate: birthDate,
                        email: email,
                        unconfirmedPhone: nil,
                        unconfirmedEmail: nil,
                        isDemo: .normal,
                        additions: [],
						profileBanners: []
                    )
                    
                    self.signUpRequest(
                        from: viewController,
                        account: account,
                        insuranceNumber: registrationUserPersonalInfo.insuranceId,
                        agreedToPersonalDataPolicy: registrationUserPersonalInfo.agreementConfirmed
                    ) { [weak viewController] result in
                        switch result {
                            case .success:
                                break
                            case .failure(let error):
                                guard let viewController = viewController
                                else { return }
                                
                                func showErrorInSection() {
                                    if let message = error.message {
                                        viewController.notify.update(.data(nil))
                                        viewController.notify.showErrorInSection(message)
                                    } else {
                                        viewController.notify.update(.failure(
                                            title: NSLocalizedString("auth_sign_up_request_common_error_title", comment: ""),
                                            description: NSLocalizedString("auth_sign_up_common_error_description", comment: "")
                                        ))
                                    }
                                }
                                
                                switch error {
                                    case .api(let apiError):
                                        switch apiError.internalCode {
                                            case SignUpErrorInternalCode.agimaError.rawValue:
                                                viewController.notify.update(.data(nil))
                                                viewController.notify.showErrorInSection(apiError.message)
                                            default:
                                                viewController.notify.update(.failure(
                                                    title: NSLocalizedString("auth_sign_up_request_common_error_title", comment: ""),
                                                    description: NSLocalizedString("auth_sign_up_common_error_description", comment: "")
                                                ))
                                        }
                                    case .network(let networkError):
                                        if networkError.isUnreachableError {
                                            viewController.notify.update(.data(nil))
                                            showNetworkUnreachableBanner()
                                        } else {
                                            showErrorInSection()
                                        }
									case .error, .infoMessage:
                                        showErrorInSection()
                                }
                        }
                    }
                }
            },
            showDocument: { url in
                WebViewer.openDocument(url, from: viewController)
            },
            toChat: {
                self.openChatFullscreen(from: viewController)
            },
            retry: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                updateRegisterTerms(on: viewController)
            },
            close: { [weak viewController] in
                self.navigationController?.popViewController(animated: true)
            }
        )
        
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func signIn(initialAuthType: SignInInitialAuthType) -> UIViewController {
        switch initialAuthType {
            case .noAuth:
                return createSignInViewController()
            case .pinCode:
                return createEnterPincodeViewController()
            case .biometricCanceled, .biometricError:
                return UIViewController()
        }
    }
	
	// swiftlint:disable:next function_body_length
    private func createSignInViewController() -> ViewController
	{
        let viewController = SignInViewController()
        container?.resolve(viewController)

        viewController.output = .init(
            goBack: {
                self.navigationController?.popViewController(animated: true)
            },
            forgotPassword: showForgotPassword,
            signIn: { [weak viewController] authType in
                guard let viewController = viewController
                else { return }
                
                viewController.notify.update(.loading)
                
                switch authType
				{
					case .phone(let unformattedPhone):
						self.authWithSMSCode(
							viewController: viewController,
							unformattedPhone: unformattedPhone
						)
					
					case .emailAndPassword(let login, let password):
						self.authWithEmailAndPassword(
							login: login,
							password: password,
							viewController: viewController
						)
					}
				
                self.analytics.track(event: AnalyticsEvent.Launch.registerProceed)
            },
            toChat: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                self.openChatFullscreen(from: viewController)
            },
            openLink: { [weak viewController] url in
                guard let viewController = viewController
                else { return }
                
                SafariViewController.open(url, from: viewController)
            },
            showAllRegistrationMethods: { [weak viewController] in
                guard let viewController = viewController
                else { return }
				
				func dismissVC(viewController: ViewController?, completion: @escaping (() -> Void))
				{
					viewController?.dismiss(
						animated: true,
						completion: completion
					)
				}
				
				AuthorizationBottomSheet.showAllRegistrationMethodsBottomSheet(
					from: viewController,
					registration: { [weak viewController] in
						dismissVC(
							viewController: viewController,
							completion: { [weak viewController] in
								guard let viewController 
								else { return }
								
								self.showRegistration(from: viewController)
							}
						)
					},
					gosuslugi: { [weak viewController] in
						dismissVC(
							viewController: viewController,
							completion: { [weak viewController] in
								guard let viewController
								else { return }
								
								self.showEsiaSignIn(
									viewController: viewController
								)
							}
						)
					},
					email: { [weak viewController] in
						dismissVC(
							viewController: viewController,
							completion: { [weak viewController] in
								guard let viewController
								else { return }
								
								viewController.notify.updateSelectedTabSwitch(1)
							}
						)
					},
					phone: { [weak viewController] in
						dismissVC(
							viewController: viewController,
							completion: { [weak viewController] in
								guard let viewController
								else { return }
								
								viewController.notify.updateSelectedTabSwitch(0)
							}
						)
					}
				)
            },
            close: {
                self.navigationController?.popViewController(animated: true)
            }
        )
        return viewController
    }
	
	private func authWithSMSCode(
		viewController: SignInViewController,
		unformattedPhone: String
	)
	{
		self.sessionService.authWithSMSCode(
			phoneNumber: unformattedPhone,
			completion: { result in
				switch result
				{
					case .success(let data):
						viewController.notify.update(.data)
						self.showSignInSMSCodeViewController(
							from: viewController,
							authSmsCode: data
						)
					
					case .failure(let error):
					
						func handleError() {
							if let errorMessage = error.message {
								viewController.notify.update(.data)
								viewController.notify.showError(errorMessage)
							} else {
								viewController.notify.update(.failure)
							}
						}
					
						func dismissVC(viewController: ViewController?, completion: @escaping (() -> Void))
						{
							viewController?.dismiss(
								animated: true,
								completion: completion
							)
						}
					
						switch error
						{
							case .infoMessage(let infoMessage):
								viewController.notify.updateColorBorderTextFieldAndState(
									true,
									.data
								)
							
								self.showSignInError(
									from: viewController,
									infoMessage: infoMessage,
									registration:
								 {
									 [weak viewController] in
									 
									 dismissVC(
										viewController: viewController,
										completion:
									 {
										[weak viewController] in
										 
										 guard let viewController
										 else { return }
										 
										 self.showRegistration(
											from: viewController
										 )
									 })
								 },
									gosuslugi:
								 {
									 [weak viewController] in
									 
									 dismissVC(
										viewController: viewController,
										completion:
									 {
										[weak viewController] in
										 
										 guard let viewController
										 else { return }
										 
										 self.showEsiaSignIn(
											viewController: viewController
										)
									 })
								 },
									email:
								 {
									[weak viewController] in
									 
									 dismissVC(
										viewController: viewController,
										completion:
									 {
										[weak viewController] in
										 
										 guard let viewController
										 else { return }
										 
										 viewController.notify.updateSelectedTabSwitch(1)
									 })
								 }
								)
							
							case .network:
								viewController.notify.update(.data)
								showNetworkUnreachableBanner()
							
							case .api(let apiError):
								viewController.notify.updateColorBorderTextFieldAndState(true, .data)
								viewController.notify.showError(apiError.message)
							
							case .error:
								handleError()
					}
				}
			}
		)
	}
	
	private func authWithEmailAndPassword(
		login: String,
		password: String,
		viewController: SignInViewController
	)
	{
		self.signIn(
			login: login,
			password: password,
			accountType: .alfaStrah
		) { result in
			switch result {
				case .success:
					viewController.notify.update(.data)
				
					self.analytics.track(
						event: AnalyticsEvent.Launch.signInSuccess,
						properties: [ AnalyticsParam.Launch.authorizationType: "АС" ]
					)
				case .failure(let error):
					func handleError() {
						if let errorMessage = error.message {
							viewController.notify.update(.data)
							viewController.notify.showError(errorMessage)
						} else {
							viewController.notify.update(.failure)
						}
					}
				
					switch error {
						case .network(let networkError):
							if networkError.isUnreachableError {
								viewController.notify.update(.data)
								showNetworkUnreachableBanner()
							} else {
								handleError()
							}
						case .api(let apiError):
							switch apiError.internalCode {
								case SignInErrorInternalCode.agimaError.rawValue,
									SignInErrorInternalCode.attemptsLeft.rawValue:
									handleError()
								case SignInErrorInternalCode.attemptsLimitExceeded.rawValue:
									self.showApiErrorAlert(
										with: apiError,
										from: viewController,
										onConfirm: { [weak viewController] in
											viewController?.notify.update(.data)
										}
									)
								default:
									handleError()
							}
						
						case .error, .infoMessage:
							handleError()
					}
				
				self.analytics.track(event: AnalyticsEvent.Launch.signInError)
			}
		}
	}
	
	private func showSignInError(
		from: ViewController,
		infoMessage: InfoMessage,
		registration: @escaping (() -> Void),
		gosuslugi: @escaping (() -> Void),
		email: @escaping (() -> Void),
		completion: (() -> Void)? = nil
	)
	{
		guard let infoMessageType = infoMessage.type
		else { return }
		
		switch infoMessageType
		{
			case .screen:
				break
			
			case .alert:
				showSignInErrorAlert(
					from: from,
					title: infoMessage.titleText ?? "",
					description: infoMessage.desciptionText ?? "",
					completion: completion
				)
			case .popup:
				AuthorizationBottomSheet.showErrorOTPAuthorizationBottomSheet(
					from: from,
					title: infoMessage.titleText ?? "",
					description: infoMessage.desciptionText ?? "",
					registration: registration,
					gosuslugi: gosuslugi,
					email: email
				)
		}
	}
	
	private func showSignInErrorAlert(
		from: ViewController,
		title: String,
		description: String,
		completion: (() -> Void)? = nil
	) {
		let alert = UIAlertController(
			title: title,
			message: description,
			preferredStyle: .alert
		)

		let cancelAction = UIAlertAction(
			title: NSLocalizedString("common_understand", comment: ""),
			style: .cancel,
			handler: { _ in completion?() }
		)

		alert.addAction(cancelAction)

		from.present(alert, animated: true)
	}
	
	private func showSignInSMSCodeViewController(
		from: SignInViewController,
		authSmsCode: AuthSmsCode
	)
	{
		let viewController = SignInSMSCodeViewController()
		container?.resolve(viewController)
		
		viewController.input = .init(
			phoneDisplayString: authSmsCode.phone.humanReadable,
			isMaskedPhoneNumber: true,
			resendSmsCodeTimer: TimeInterval(authSmsCode.codeTime)
		)
		
		viewController.output = .init(
			goBack: {
				self.navigationController?.popViewController(animated: true)
			},
			toChat: { [weak viewController] in
				guard let viewController = viewController
				else { return }
				
				self.openChatFullscreen(from: viewController)
			},
			verify: 
			{
				code in
				
				let hide = from.showLoadingIndicator(
					message: NSLocalizedString("auth_sign_up_data_loading_title", comment: "")
				)
				
				self.sessionService.confirmSMSCode(
					phone: authSmsCode.phone.plain,
					code: code,
					completion:
					{
						[weak viewController, weak from] result in
						
						hide(nil)
						
						switch result
						{
							case .success:
								self.applicationSettingsService.wasAutorized = true
								if self.applicationSettingsService.userAuthType == .notDefined 
								{
									self.createAndShowNavigationController(
										viewController: self.createSetPincodeController(),
										mode: .push
									)
								}
							
							case .failure(let error):
								guard let viewController,
									  let from
								else { return }
							
								self.showSignInSMSCodeError(
									parentViewController: from,
									from: viewController,
									error: error
								)
						}
					}
				)
			},
			resendSms: { 
				let hide = from.showLoadingIndicator(
					message: NSLocalizedString("auth_sign_up_data_loading_title", comment: "")
				)
				
				self.sessionService.resendSMSCode(
					phoneNumber: authSmsCode.phone.plain,
					completion:
					{
						[weak viewController, weak from] result in
						
						hide(nil)
						switch result
						{
							case .success(let data):
								viewController?.notify.updateSmsCodeTimer(
									TimeInterval(data.codeTime)
								)
							
							case .failure(let error):
								guard let viewController,
									  let from
								else { return }
							
								self.showSignInSMSCodeError(
									parentViewController: from,
									from: viewController,
									error: error
								)
						 }
					})
			}
		)
		
		from.navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func showSignInSMSCodeError(
		parentViewController: SignInViewController,
		from: SignInSMSCodeViewController,
		error: AlfastrahError
	)
	{
		func dismissVC(viewController: ViewController?, completion: @escaping (() -> Void))
		{
			viewController?.dismiss(
				animated: true,
				completion: completion
			)
		}
	
		switch error
		{
			case .infoMessage(let infoMessage):
				self.showSignInError(
					from: from,
					infoMessage: infoMessage,
					registration:
				 {
					 [weak from] in
					 
					 dismissVC(
						viewController: from,
						completion:
					 {
						 [weak parentViewController] in
						 
						 guard let parentViewController
						 else { return }
						 
						 self.navigationController?.popViewController(animated: false)
						 self.showRegistration(
							from: parentViewController
						 )
					 })
				 },
					gosuslugi:
				 {
					 [weak from] in
					 
					 dismissVC(
						viewController: from,
						completion:
					 {
						 [weak parentViewController] in
						 
						 guard let parentViewController
						 else { return }
						 
						 self.navigationController?.popViewController(animated: false)
						 self.showEsiaSignIn(
							viewController: parentViewController
						)
					 })
				 },
					email:
				 {
					[weak from] in
					 
					dismissVC(
						viewController: from,
						completion:
					 {
						[weak parentViewController] in
						 
						 guard let parentViewController
						 else { return }
						 
						 self.navigationController?.popViewController(animated: false)
						 parentViewController.notify.updateSelectedTabSwitch(1)
					 })
				 },
					completion:
				 {
					[weak from] in
					 
					from?.notify.showError(nil)
				 }
				)
			
			case .network:
				showNetworkUnreachableBanner()
			
			case .api(let apiError):
				from.notify.showError(apiError.message)
			
			case .error:
				ErrorHelper.show(error: error, alertPresenter: from.alertPresenter)
		}
	}

    private func signUpRequest(
        from: ViewController,
        account: Account,
        insuranceNumber: String?,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        let hide = from.showLoadingIndicator(message: NSLocalizedString("auth_sign_up_request_loading_description", comment: ""))

        mobileDeviceTokenService.getDeviceToken { [weak self] deviceTokenResult in
            guard let self = self else { return }

            switch deviceTokenResult {
                case .success(let deviceToken):
                    self.accountService.register(
                            account: account,
                            insuranceNumber: insuranceNumber ?? "",
                            deviceToken: deviceToken,
                            agreedToPersonalDataPolicy: agreedToPersonalDataPolicy
                    ) { [weak self] result in
                        guard let self = self else { return }

                        hide(nil)
                        switch result {
                            case .success(let accountResponse):
                                self.account = accountResponse.account
                                
                                self.processToSmsVerification(
                                    accountId: accountResponse.account.id,
                                    phoneNumber: accountResponse.maskedPhoneNumber,
                                    isMaskedPhoneNumber: true,
                                    otpVerificationResendTimeInterval: accountResponse.otpVerificationResendTimeInterval
                                )
                                
                                completion(.success(()))
                            case .failure(let error):
                                self.analytics.track(event: AnalyticsEvent.Launch.registerError)
                                self.account = nil

                                completion(.failure(error))
                        }
                    }

                case .failure(let error):
                    hide(nil)
                    self.analytics.track(event: AnalyticsEvent.Launch.registerError)
                    self.account = nil
                    completion(.failure(error))
            }
        }
    }
    
    private func processToSmsVerification(
        accountId: String,
        phoneNumber: String,
        isMaskedPhoneNumber: Bool,
        otpVerificationResendTimeInterval: TimeInterval
    ) {
        let viewController = SmsCodeViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            phoneDisplayString: phoneNumber,
            isMaskedPhoneNumber: isMaskedPhoneNumber,
            resendSmsCodeTimer: TimeInterval(otpVerificationResendTimeInterval)
        )
        
        viewController.output = .init(
            verify: { [weak viewController] code in
                guard let viewController = viewController
                else { return }
                
                self.verifyRegistration(
                    from: viewController,
                    code: code,
                    accountId: accountId,
                    confirm: { [weak viewController] in
                        viewController?.notify.bringFocusToOtp()
                    }
                ) { [weak viewController] message in
                    viewController?.notify.otpVerificationFailed(message)
                }
            },
            resendSms: resendSmsRequest,
            openChat: { [weak viewController] in
                guard let controller = viewController
                else { return }

                self.openChatFullscreen(from: controller)
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }
	
	private func askForDateOfBirth(
		accountId: String,
		phoneNumber: String,
		email: String
	) {
		let viewController = DateOfBirthViewController()
		container?.resolve(viewController)
		
		viewController.output = .init(
			verify: { [weak viewController] birthday in
				guard let viewController = viewController
				else { return }
				
				let hide = viewController.showLoadingIndicator(message: NSLocalizedString("date_of_birth_screen_loading", comment: ""))

				self.accountService.checkBirthday(
					accountId: accountId,
					birthday: birthday,
					email: email
				) { [weak self] result in

					hide(nil)

					guard let self
					else { return }

					switch result {
						case .success(let response):
							let viewController = EmailAndCodeInputsViewController()

							viewController.input = .init(
								phoneNumber: response.phone.humanReadable,
								email: response.email,
								resendSmsCodeTimer: response.smsCodeVerificationResendTimeInterval,
								resendEmailCodeTimer: response.emailCodeVerificationResendTimeInterval
							)

							viewController.output = .init(
								openChat: { [weak viewController] in
									guard let controller = viewController
									else { return }

									self.openChatFullscreen(from: controller)
								},
								resendSms: {
									self.accountService.resendPartnerSmsCode(
										accountId: accountId
									) { [weak self] result in
										guard let self
										else { return }
										
										switch result {
											case .success(let response):
												viewController.smsCodeResended(resendSmsCodeTimer: response.smsCodePartnerResendTimeInterval)
											case .failure(let error):
												ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
										}
									}
								},
								resendEmailCode: {
									self.accountService.resendPartnerEmailCode(
										accountId: accountId
									) { [weak self] result in
										guard let self
										else { return }
										
										switch result {
											case .success(let response):
												viewController.emailCodeResended(resendEmailCodeTimer: response.emailCodePartnerResendTimeInterval)
											case .failure(let error):
												ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
										}
									}
								},
								validationPassed: { [weak viewController] emailCode, smsCode in
									guard let viewController
									else { return }
									
									let hide = viewController.showLoadingIndicator(message: NSLocalizedString("date_of_birth_screen_loading", comment: ""))
									
									self.accountService.checkPartnerCodes(
										accountId: accountId,
										emailCode: emailCode,
										smsCode: smsCode
									) { [weak self] result in
										hide(nil)

										guard let self
										else { return }
										
										switch result {
											case .success(let response):
												self.showCreateNewPassword(for: accountId, with: response.password)
											case .failure(let error):
												viewController.showError(errorMessage: error.message)
										}
									}
								}
							)
							
							self.navigationController?.pushViewController(viewController, animated: true)

						case .failure(let error):
							viewController.showError(errorText: error.message ?? "")
					}
					
				}
			},
			openChat: { [weak viewController] in
				guard let controller = viewController
				else { return }

				self.openChatFullscreen(from: controller)
			}
		)

		createAndShowNavigationController(viewController: viewController, mode: .push)
	}

    private func resendSmsRequest() {
        guard let accountId = accountId else { return }

        accountService.resendSms(accountId: accountId) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success:
                    break
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func verifyRegistration(
        from: ViewController,
        code: String,
        accountId: String,
        confirm: @escaping () -> Void,
        failure: @escaping (String) -> Void
    ) {
        accountService.confirmCode(code, accountId: accountId) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let passwordOtpConfirmed):
                    if let navigationController = self.navigationController {
                        var viewControllers = navigationController.viewControllers
                        
                        let createNewPasswordViewController = self.createCreateNewPasswordViewController(
                            for: accountId,
                            with: passwordOtpConfirmed
                        )
                        
                        viewControllers.removeLast()
                        viewControllers.append(createNewPasswordViewController)
                        
                        navigationController.setViewControllers(viewControllers, animated: true)
                    }

                    self.applicationSettingsService.showFirstAlphaPoints = true
                case .failure(let error):
                    var message = ""
                
                    switch error {
                        case .api(let apiError):
                            switch apiError.internalCode {
                                case OtpConfirmInternalCode.attemptsLeft.rawValue:
                                    message = apiError.message
                                case OtpConfirmInternalCode.attemptsLimitExceeded.rawValue, OtpConfirmInternalCode.invalid.rawValue:
                                    self.showApiErrorAlert(
                                        with: apiError,
                                        from: from,
                                        onConfirm: confirm
                                    )
                                default:
                                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                            }
						case .network, .error, .infoMessage:
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                    
                    failure(message)
            }
        }
    }

   private func showApiErrorAlert(
        with error: APIError,
        from: ViewController,
        onConfirm: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: error.title,
            message: error.message,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(
            title: NSLocalizedString("auth_sign_up_alert_confirm_button_title", comment: ""),
            style: .default
        ) { _ in
            onConfirm?()
        }
        
        alert.addAction(confirmAction)
        
        from.present(
            alert,
            animated: true
        )
    }
    
	func showCreateNewPassword(for accountId: String, with oldPassword: String) {
		let viewController = createCreateNewPasswordViewController(for: accountId, with: oldPassword)

		createAndShowNavigationController(viewController: viewController, mode: .push)
    }

	private func createSetPincodeControllerAndShowHome() -> UIViewController {
		createSetPincodeController() {
			ApplicationFlow.shared.show(item: .tabBar(.home)) {
				self.navigationController?.popToRootViewController(animated: false)
			}
		}
	}

    private func createCreateNewPasswordViewController(for accountId: String, with oldPassword: String) -> ViewController {
        func updateRequirements() {
            viewController.notify.update(.loading)
            
            accountService.passwordRequirements { result in
                switch result {
                    case .success(let passwordsRequirements):
                        viewController.notify.update(.data(passwordsRequirements))
                    case .failure(let error):
                        viewController.notify.update(.failure)
                }
            }
        }
        
        let viewController = CreateNewPasswordViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            updateRequirements: {
                updateRequirements()
            }
        )
        
        viewController.output = .init(
            saveNewPassword: { [weak viewController] newPassword in
                guard let viewController = viewController
                else { return }

                let hide = viewController.showLoadingIndicator(message: nil)

                self.updatePassword(newPassword, oldPassword: oldPassword, accountId: accountId) { [weak viewController] result in
                    hide(nil)
                    guard let viewController = viewController
                    else { return }
                    switch result {
                        case .success(let account):
                            self.analytics.track(event: AnalyticsEvent.Launch.registerSuccess)
                            self.applicationSettingsService.login = account.email
                            self.applicationSettingsService.password = newPassword

							self.createAndShowNavigationController(
								viewController: self.createSetPincodeControllerAndShowHome(),
								mode: .push
							)
                        case .failure(let error):
                            func handleError() {
                                if let errorMessage = error.message {
                                    viewController.notify.update(.data(nil))
                                    viewController.notify.showError(errorMessage)
                                } else {
                                    viewController.notify.update(.failure)
                                }
                            }
                            
                            switch error {
                                case .network(let networkError):
                                    if networkError.isUnreachableError {
                                        viewController.notify.update(.data(nil))
                                        showNetworkUnreachableBanner()
                                    } else {
                                        handleError()
                                    }
								case .api, .error, .infoMessage:
                                    handleError()
                            }
                    }
                }
            },
            toChat: {
                self.openChatFullscreen(from: viewController)
            },
            retry: {
                updateRequirements()
            },
            close: { [weak viewController] in
                self.navigationController?.popViewController(animated: true)
            }
        )
        
        return viewController
    }
    
    private func openChatFullscreen(from: ViewController) {
        if self.chatFlow == nil {
            let chatFlow = ChatFlow()
            container?.resolve(chatFlow)
            
            self.chatFlow = chatFlow
        }
        
        self.chatFlow?.show(from: from, mode: .fullscreen)
    }

    private func updatePassword(
        _ password: String,
        oldPassword: String,
        accountId: String,
        completion: @escaping (Result<Account, AlfastrahError>) -> Void
    ) {
        accountService.updatePassword(password, oldPassword: oldPassword, accountId: accountId) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let response):
                    if response.success {
                        self.mobileDeviceTokenService.getDeviceToken { [weak self] deviceTokenResult in
                            guard let self = self else { return }

                            switch deviceTokenResult {
                                case .success(let deviceToken):
                                    self.sessionService.auth(
                                        login: response.account.email,
                                        password: password,
                                        type: self.applicationSettingsService.accountType,
                                        isDemo: .normal,
                                        deviceToken: deviceToken
                                    ) { result in
                                        completion(result)
                                    }

                                case .failure(let error):
                                    completion(.failure(error))
                            }
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    private func showForgotPassword() {
        let viewController = ForgottenPasswordViewController()
        container?.resolve(viewController)
        viewController.output = .init(
            resetPassword: { phone, email in
				let hide = viewController.showLoadingIndicator(message: NSLocalizedString("date_of_birth_screen_loading", comment: ""))
                self.accountService.resetPassword(email: email, phone: phone) { result in
                    hide(nil)
                    switch result {
                        case .success(let response):
                            self.accountId = response.accountId
                            viewController.notify.update(.data)
							switch response.passRecoveryFlow {
								case .regular:
									self.processToSmsVerification(
										accountId: response.accountId,
										phoneNumber: response.phone.plain,
										isMaskedPhoneNumber: false,
										otpVerificationResendTimeInterval: response.otpVerificationResendTimeInterval
									)
								case .partner:
									self.askForDateOfBirth(
										accountId: response.accountId,
										phoneNumber: response.phone.plain,
										email: email
									)
							}
                        case .failure(let error):
                            self.accountId = nil
                            func handleError() {
                                if let errorMessage = error.message {
                                    viewController.notify.update(.data)
                                    viewController.notify.showError(errorMessage)
                                } else {
                                    viewController.notify.update(.failure)
                                }
                            }
                            
                            switch error {
                                case .network(let networkError):
                                    if networkError.isUnreachableError {
                                        viewController.notify.update(.data)
                                        showNetworkUnreachableBanner()
                                    } else {
                                        handleError()
                                    }
								case .api, .error, .infoMessage:
                                    handleError()
                            }
                    }
                }
            },
            toChat: {
                self.openChatFullscreen(from: viewController)
            },
            close: { [weak viewController] in
                viewController?.navigationController?.popViewController(animated: true)
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showActivateInsurance(fromVC: ViewController) {
        let flow = ActivateProductFlow()
        container?.resolve(flow)
        flow.startModally(from: fromVC)
    }

    private func startDemoMode(viewController: UIViewController) {
        serviceDataManager.erase(logout: true)
        let hide = viewController.showLoadingIndicator(message: NSLocalizedString("auth_spinner_title", comment: ""))

        self.mobileDeviceTokenService.getDeviceToken { [weak self] deviceTokenResult in
            guard let self = self
            else { return }
            
            /// необходимо установить userAuthType до того как sessionService.auth установит токен сессии
            /// иначе контроллер чата будет в неправильном состоянии
            self.applicationSettingsService.userAuthType = .demo
            self.applicationSettingsService.login = "demo"
            self.applicationSettingsService.password = "demo"
            
            switch deviceTokenResult {
                case .success(let deviceToken):
                    self.sessionService.auth(
                        login: "",
                        password: "",
                        type: .alfaStrah,
                        isDemo: .demo,
                        deviceToken: deviceToken
                    ) { [weak self] result in
                        guard let self = self else { return }

                        switch result {
                            case .success:
                                hide {
									self.updateServicesAndClose
									{
										ApplicationFlow.shared.refreshAllTabs()
									}
                                }
                            case .failure(let error):
                                self.applicationSettingsService.userAuthType = .notDefined
                                self.applicationSettingsService.login = ""
                                self.applicationSettingsService.password = ""
                                hide(nil)
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                        }
                    }

                case .failure(let error):
                    hide(nil)
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func signIn(
        login: String,
        password: String,
        accountType: AccountType,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        if applicationSettingsService.userAuthType != .notDefined && !(applicationSettingsService.login == login) {
            serviceDataManager.erase(logout: true)
            stopInactivityTimer()
        }

        self.mobileDeviceTokenService.getDeviceToken { [weak self] deviceTokenResult in
            guard let self = self else { return }

            switch deviceTokenResult {
                case .success(let deviceToken):
                    self.sessionService.auth(
                        login: login,
                        password: password,
                        type: accountType,
                        isDemo: .normal,
                        deviceToken: deviceToken
                    ) { [weak self] result in
                        guard let self = self else { return }

                        switch result {
                            case .success:
                                completion(.success(()))
                                self.applicationSettingsService.wasAutorized = true
                                if self.applicationSettingsService.userAuthType == .notDefined {
                                    self.createAndShowNavigationController(
                                        viewController: self.createSetPincodeController(),
                                        mode: .push
                                    )
                                }
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }

                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    private func showSetPin(completion: @escaping (String) -> Void) {
        let viewController: SetPinCodeViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.output = .init(
            submitCode: completion
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showAuthMethod() {
        let viewController: AuthMethodViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.output = .init(
            grantAutoAuth: {
                self.updateAuthType(.auto)
                self.updateServicesAndClose()
            },
            denyAutoAuth: denyAutoAuth
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func denyAutoAuth() {
        guard let topModalVC = UIHelper.topViewController() else { return }

        let message: String
        let action: (UIAlertAction) -> Void
        if biometricsAuthService.available {
            message = biometricsAuthService.type == .faceID
                ? NSLocalizedString("auth_invitation_face_id", comment: "")
                : NSLocalizedString("auth_invitation_touch_id", comment: "")
            action = { _ in
                self.updateAuthType(.biometric)
                self.updateServicesAndClose()
            }
        } else {
            message = NSLocalizedString("auth_invitation_pin", comment: "")
            action = { _ in
                self.showSetPin { password in
                    self.applicationSettingsService.pin = password
                    self.updateAuthType(.pin)
                    self.updateServicesAndClose()
                }
            }
        }
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
        alert.addAction(cancelAction)
        let continueAction = UIAlertAction(title: NSLocalizedString("common_continue", comment: ""), style: .default, handler: action)
        alert.addAction(continueAction)
        topModalVC.present(alert, animated: true)
    }

    private func updateAuthType(_ userAuthType: AuthType) {
        applicationSettingsService.userAuthType = userAuthType
        applicationSettingsService.wasAutorized = true
    }

    // MARK: - App availability

    private func createUpdateAppViewController(
        _ appAvailable: AppAvailable
    ) -> UpdateAppViewController {
        let controller: UpdateAppViewController = storyboard.instantiate()
        controller.navigationItem.hidesBackButton = true
        container?.resolve(controller)
        controller.input = .init(appAvailable: appAvailable)
        controller.output = .init(
            onClose: { [weak controller] in
                switch appAvailable.status {
                    case .fullyAvailable, .partlyBlocked:
                        controller?.dismiss(animated: true)
                    case .totalyBlocked:
                        return
                }
            }
        )
        return controller
    }

    // MARK: - Navigation

    /// Closes auth flow
    private func updateServicesAndClose(completion: (() -> Void)? = nil) {
        self.localServicesUpdate()

        self.close {
            self.flowCompletionHandler?()
            completion?()
        }
    }

    override func close(completion: (() -> Void)? = nil) {
        initialAuthFinished = true
        super.close(completion: completion)
    }
    
    // MARK: - Screen lock on user inactivity
    private var inactivityTimer: Timer?
    private let activityValidateTimeInterval: TimeInterval = 3 * 60 * 60

    private func startInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
        
        inactivityTimer = Timer.scheduledTimer(
            timeInterval: activityValidateTimeInterval,
            target: self,
            selector: #selector(timerPeriodExceeded(_:)),
            userInfo: nil,
            repeats: false
        )
    }

    private func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }

    @objc private func timerPeriodExceeded(_ timer: Timer) {
        ApplicationFlow.shared.show(item: .pincode)
    }

    private func fireDate() -> Date {
        return Date().addingTimeInterval(activityValidateTimeInterval)
    }

    func resetInactivityTimer() {
        guard let inactivityTimer = inactivityTimer
        else { return }

        if inactivityTimer.isValid {
            inactivityTimer.fireDate = fireDate()
        }
    }
}
// swiftlint:enable file_length
