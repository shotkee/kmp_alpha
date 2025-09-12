//
//  SecuritySettingsViewController.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/28/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

final class SecuritySettingsViewController: ViewController, ApplicationSettingsServiceDependency, BiometricsAuthServiceDependecy {
    var applicationSettingsService: ApplicationSettingsService!
    var biometricsAuthService: BiometricsAuthService!
    
    struct Output {
        let saveNewPassword: () -> Void
    }

    var output: Output!

    @IBOutlet private var entryByBiometricsView: UIView!
    @IBOutlet private var fastAuthTitleLabel: UILabel!
    @IBOutlet private var entryByBiometricsSwitch: UISwitch!
    @IBOutlet private var updateFastAuthContainerView: UIView!
    @IBOutlet private var changePasswordTitleLabel: UILabel!
    @IBOutlet private var changeFastAccessCodeTitleLabel: UILabel!
	@IBOutlet private var changePasswordAccessoryImageView: UIImageView!
	@IBOutlet private var changePasswordView: UIView!
	@IBOutlet private var updateFastAuthAccessoryImageView: UIImageView!
	
	private var selectedUserAuthType: AuthType? {
        didSet {
            guard let selectedUserAuthType = selectedUserAuthType else { return }

            applicationSettingsService.userAuthType = selectedUserAuthType
            configureForUserAuthType(selectedUserAuthType)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("user_profile_login_settings", comment: "")
        changePasswordTitleLabel <~ Style.Label.primaryText
        changePasswordTitleLabel.text = NSLocalizedString("security_settings_change_password_title", comment: "")
        
        changeFastAccessCodeTitleLabel <~ Style.Label.primaryText
        changeFastAccessCodeTitleLabel.text = NSLocalizedString("security_settings_change_access_code", comment: "")
        
        fastAuthTitleLabel <~ Style.Label.primaryText

        selectedUserAuthType = applicationSettingsService.userAuthType

        // Don't have to check entry by biometrics, since the title will be hidden along with the label
        fastAuthTitleLabel.text = NSLocalizedString("security_settings_entry_by", comment: "")
			+ " " + (applicationSettingsService.authTypeTitle(.biometric) ?? "")
		
		changePasswordView.backgroundColor = .Background.backgroundSecondary
		updateFastAuthContainerView.backgroundColor = .Background.backgroundSecondary
		entryByBiometricsView.backgroundColor = .Background.backgroundSecondary
		
		changePasswordAccessoryImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
		updateFastAuthAccessoryImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
    }

    private func changeFastAuthEnabled(_ isEnabled: Bool) {
        
        func getAuthType() -> AuthType {
            switch biometricsAuthService.type {
                case .none:
                    return .pin
                case .touchID, .faceID:
                    return .biometric
            }
        }
        
        self.entryByBiometricsSwitch.isOn = isEnabled
        
        if isEnabled, (biometricsAuthService.type == .faceID || biometricsAuthService.type == .touchID) {
            let touchIdReason = self.biometricsAuthService.type == .faceID
                ? NSLocalizedString("auth_face_id_reason", comment: "")
                : NSLocalizedString("auth_touch_id_reason", comment: "")
            
            self.biometricsAuthService.authenticate(
                reason: touchIdReason,
                completion: { [weak self] result in
                    guard let self = self
                    else { return }
                    
                    switch result {
                        case .success:
                            self.applicationSettingsService.userAuthType = getAuthType()
                        case .failure:
                            break
                    }
                }
            )
        } else {
            guard let pin = self.applicationSettingsService.pin,
                  !pin.isEmpty
            else {
                self.applicationSettingsService.userAuthType = .full
                return
            }
			
            self.applicationSettingsService.userAuthType = .pin
        }
    }

    private func configureForUserAuthType(_ userAuthType: AuthType) {
        switch userAuthType {
            case .full:
                entryByBiometricsSwitch.isOn = false
            case .auto:
                entryByBiometricsSwitch.isOn = false
            case .pin:
                entryByBiometricsSwitch.isOn = !biometricsAuthService.available
            case .biometric:
                entryByBiometricsSwitch.isOn = true
            case .demo:
                // TODO: What's the expected behavior here?
                break
            case .notDefined:
                fatalError("Internal inconsistency!")
        }
        
        entryByBiometricsView.isHidden = !biometricsAuthService.available
    }

    @IBAction private func closeTap(_ sender: UIBarButtonItem) {
        parent?.dismiss(animated: true, completion: nil)
    }

    @IBAction private func fastAuthSwitchTap(_ sender: UITapGestureRecognizer) {
        changeFastAuthEnabled(!entryByBiometricsSwitch.isOn)
    }

    @IBAction private func updateFastAuthCodeTap(_ sender: UIButton) {
        let authorizationFlow = AuthorizationFlow(rootController: self)
        container?.resolve(authorizationFlow)
        let createPincodeViewController = authorizationFlow.createSetPincodeController(changePinCode: true)
        authorizationFlow.createAndShowNavigationController(
            viewController: createPincodeViewController,
            mode: .push
        )
    }

    @IBAction private func updatePasswordTap(_ sender: UIButton) {
        output.saveNewPassword()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let changePassworAccessoryImage = changePasswordAccessoryImageView.image
		changePasswordAccessoryImageView.image = changePassworAccessoryImage?.tintedImage(withColor: .Icons.iconSecondary)
		
		let fastAuthImage = updateFastAuthAccessoryImageView.image
		
		updateFastAuthAccessoryImageView.image = fastAuthImage?.tintedImage(withColor: .Icons.iconSecondary)
	}
}
