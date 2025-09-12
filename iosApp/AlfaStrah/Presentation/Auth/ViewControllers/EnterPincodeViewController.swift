//
//  EnterPincodeViewController.swift
//  AlfaStrah
//
//  Created by vit on 27.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import TinyConstraints

class EnterPincodeViewController: ViewController,
                                  BiometricsAuthServiceDependecy {
    var biometricsAuthService: BiometricsAuthService!
    
	private let primaryContainerStackView = UIStackView()
	private let secondaryContainerStackView = UIStackView()
    private let pincodeKeyboardView = PincodeKeyboardView()
	private var activityIndicatorView = ActivityIndicatorView(frame: .zero)
	
	struct Notify {
		let update: (_ numberOfAttemps: Int?) -> Void
	}
	
	private(set) lazy var notify = Notify(
		update: { [weak self] numberOfAttemps in
			guard let self = self,
				  self.isViewLoaded
			else { return }

			self.update(numberOfAttempts: numberOfAttemps)
		}
	)
	
    struct Input {
        let userAuthType: AuthType
        let code: String?
		var numberOfAttempts: Int?
    }

    struct Output {
        let codeEntered: (Result<String, PincodeKeyboardView.PincodeError>) -> Void
        let close: () -> Void
		let attemptsExhausted: () -> Void
        let biometricAuthenticated: (Result<Void, BiometricsAuthError>) -> Void
    }

    var input: Input!
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("auth_enter_pincode_navigation_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
                
		setupPincodeKeyboardView()
		setupTitleLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch input.userAuthType {
            case .biometric:
                if biometricsAuthService.available {
                    biometricsAuthenticate()
                }
            case .full, .notDefined, .pin, .auto, .demo:
                break
        }
    }

	private func update(numberOfAttempts: Int?) {
		input.numberOfAttempts = numberOfAttempts
		setupTitleLabel()
	}
    
    private func setupPincodeKeyboardView() {
        view.addSubview(pincodeKeyboardView)
		pincodeKeyboardView.width(232)
		pincodeKeyboardView.centerXToSuperview()
		pincodeKeyboardView.bottomToSuperview(offset: -36, usingSafeArea: true)
        
        switch input.userAuthType {
            case .biometric:
                pincodeKeyboardView.biometryIsAvailable = biometricsAuthService.available
                pincodeKeyboardView.biometryType = biometricsAuthService.type
            case .full, .notDefined, .pin, .auto, .demo:
                break
        }

        pincodeKeyboardView.showExitButton = true
        pincodeKeyboardView.initialSequence = input.code
        pincodeKeyboardView.keysInputCompletion = { [weak self] result in
            guard let self
            else { return }

            output.codeEntered(result)
        }
        pincodeKeyboardView.close = { [weak self] in
            self?.output.close()
        }
        
        pincodeKeyboardView.biometricAuthHandler = { [weak self] in
            guard let self = self
            else { return }
            
            switch self.input.userAuthType {
                case .biometric:
                    self.biometricsAuthenticate()
                case .full, .notDefined, .pin, .auto, .demo:
                    break
            }
        }
    }
    
    private func biometricsAuthenticate() {
        let touchIdReason = self.biometricsAuthService.type == .faceID
            ? NSLocalizedString("auth_face_id_reason", comment: "")
            : NSLocalizedString("auth_touch_id_reason", comment: "")
        self.biometricsAuthService.authenticate(reason: touchIdReason, completion: self.output.biometricAuthenticated)
    }
    
	private func setupTitleLabel() {
		if let numberOfAttempts = input.numberOfAttempts, numberOfAttempts > 1 {
			if numberOfAttempts <= Constants.totalNumberOfAttempts {
				let availableLoginAttempts = Constants.totalNumberOfAttempts - numberOfAttempts + 1
				
				setupSecondaryActionTitleLabel(
					title: String(
						format: NSLocalizedString("attempts", comment: ""),
						locale: .init(identifier: "ru"),
						availableLoginAttempts
					),
					description: NSLocalizedString("auth_pincode_description", comment: "")
				)

				if availableLoginAttempts == Constants.firstNumberOfAttempts {
					confirmCodeAnimation()
				} else {
					secondaryContainerStackView.alpha = 1
				}
			} else {
				setupSecondaryActionTitleLabel(
					title: NSLocalizedString("auth_pincode_attempts_exhausted", comment: ""),
					description: NSLocalizedString("auth_pincode_attempts_exhausted_description", comment: ""),
					addLoadingIndicator: true
				)

				DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
					self.activityIndicatorView.isHidden = true
					self.output.attemptsExhausted()
				}

				pincodeKeyboardView.keyboardIsBlocked = true

				confirmCodeAnimation()
			}
		} else {
			setupPrimaryContainerStackView(title: NSLocalizedString("auth_enter_pincode_title", comment: ""), description: "")
		}
    }
	
	private func setupPrimaryContainerStackView(title: String, description: String) {
		// Don't need to resetup stack
		if !primaryContainerStackView.subviews.isEmpty {
			return
		}

		view.addSubview(primaryContainerStackView)

		primaryContainerStackView.backgroundColor = .clear
		primaryContainerStackView.axis = .vertical
		primaryContainerStackView.spacing = 9
		
		primaryContainerStackView.horizontalToSuperview(insets: .horizontal(18))
		primaryContainerStackView.height(max: 200)
		primaryContainerStackView.bottomToTop(of: pincodeKeyboardView, offset: -26)
		
		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
		titleLabel <~ Style.Label.primaryHeadline2
		
		primaryContainerStackView.addArrangedSubview(titleLabel)

		let descriptionLabel = UILabel()
		descriptionLabel.text = description
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 2
		descriptionLabel <~ Style.Label.secondaryText

		primaryContainerStackView.addArrangedSubview(descriptionLabel)
	}
		
	private func setupSecondaryActionTitleLabel(title: String, description: String, addLoadingIndicator: Bool = false) {
		if secondaryContainerStackView.subviews.isEmpty {
			view.addSubview(secondaryContainerStackView)
			secondaryContainerStackView.axis = .vertical
			secondaryContainerStackView.spacing = 9
			secondaryContainerStackView.backgroundColor = .clear
			secondaryContainerStackView.horizontalToSuperview(insets: .horizontal(18))
			secondaryContainerStackView.height(max: 200)
			secondaryContainerStackView.bottomToTop(of: pincodeKeyboardView, offset: -26)
		}
		
		secondaryContainerStackView.subviews.forEach { view in
			view.removeFromSuperview()
		}

		secondaryContainerStackView.alpha = 0
		
		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
		titleLabel <~ Style.Label.primaryHeadline2
		
		secondaryContainerStackView.addArrangedSubview(titleLabel)
		
		let descriptionLabel = UILabel()
		descriptionLabel.text = description
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 2
		descriptionLabel <~ Style.Label.secondaryText
		
		secondaryContainerStackView.addArrangedSubview(descriptionLabel)
		
		if addLoadingIndicator {
			view.addSubview(activityIndicatorView)
			activityIndicatorView.animating = true
			activityIndicatorView.height(Constants.activityIndicatorSpinnerHeight)
			activityIndicatorView.topToBottom(of: secondaryContainerStackView, offset: 5)
			activityIndicatorView.centerXToSuperview()
			activityIndicatorView.aspectRatio(1)
		}
	}
	
	private func confirmCodeAnimation() {
		primaryContainerStackView.transform = .identity
		secondaryContainerStackView.transform = secondaryContainerStackView.transform.translatedBy(x: Constants.screenWidth, y: 0)
		
		UIView.animate(withDuration: 0.5, animations: { [ weak self ] in
			guard let self = self
			else { return }
			
			self.secondaryContainerStackView.alpha = 1
			self.primaryContainerStackView.alpha = 0

			self.primaryContainerStackView.transform = self.primaryContainerStackView.transform.translatedBy(x: -Constants.screenWidth, y: 0)
			self.secondaryContainerStackView.transform = .identity
		})
	}
	
	struct Constants {
		static let totalNumberOfAttempts = 4
		static let firstNumberOfAttempts = 3
		static let activityIndicatorSpinnerHeight: CGFloat = 35
		static let screenWidth = UIScreen.main.bounds.width
	}
}
