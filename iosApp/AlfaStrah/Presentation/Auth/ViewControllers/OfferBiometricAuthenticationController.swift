//
//  OfferBiometricAuthenticationController.swift
//  AlfaStrah
//
//  Created by vit on 27.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class OfferBiometricAuthenticationController: ViewController,
                                              BiometricsAuthServiceDependecy,
                                              UIAdaptivePresentationControllerDelegate {
    var biometricsAuthService: BiometricsAuthService!
        
    struct Input {}
    
    struct Output {
        let enable: (Result<Void, BiometricsAuthError>) -> Void
        let close: () -> Void
        let dismissed: () -> Void
    }

    var input: Input!
    var output: Output!
    
    private lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(
			image: .Icons.cross,
            style: .plain,
            target: self,
            action: #selector(close)
        )
    }()
    
    private let actionButtonsStackView = UIStackView()
    private let enableButton = RoundEdgeButton()
    private let skipButton = RoundEdgeButton()
    private let containerStackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.presentationController?.delegate = self
   
        setupUI()
    }
    
    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
        
        navigationItem.rightBarButtonItem = closeButton
        
        setupContent()
        setupActionButtonStackView()
        setupSkipButton()
        setupEnableButton()
    }
    
    private func setupContent() {
        view.addSubview(containerStackView)
        
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerStackView.layoutMargins = .zero
        containerStackView.alignment = .center
        containerStackView.distribution = .fill
        containerStackView.axis = .vertical
        containerStackView.spacing = 0
        containerStackView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 190),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
        ])
        
        let isFaceId = biometricsAuthService.type == .faceID
        
        let imageName = isFaceId
            ? "ico-face-id-offer"
            : "ico-touch-id-offer"
        
		imageView.image = UIImage(named: imageName)?.tintedImage(withColor: .Icons.iconAccent)
        containerStackView.addArrangedSubview(imageView)
        
        containerStackView.addArrangedSubview(spacer(33))
        
        titleLabel.text = isFaceId
            ? NSLocalizedString("auth_face_id_offer_title", comment: "")
            : NSLocalizedString("auth_touch_id_offer_title", comment: "")
        titleLabel.numberOfLines = 0
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.textAlignment = .center
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(spacer(12))
        
        descriptionLabel.text = NSLocalizedString("auth_type_offer_description", comment: "")
        descriptionLabel.numberOfLines = 0
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.textAlignment = .center
        
        containerStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupActionButtonStackView() {
        view.addSubview(actionButtonsStackView)

        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 18, right: 18)
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = 9
        actionButtonsStackView.backgroundColor = .clear

        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSkipButton() {
        skipButton <~ Style.RoundedButton.oldOutlinedButtonSmall

        skipButton.setTitle(
            NSLocalizedString("common_skip_button", comment: ""),
            for: .normal
        )
        skipButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skipButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        actionButtonsStackView.addArrangedSubview(skipButton)
    }
    
    private func setupEnableButton() {
        enableButton <~ Style.RoundedButton.oldPrimaryButtonSmall

        enableButton.setTitle(
            NSLocalizedString("common_turn_on", comment: ""),
            for: .normal
        )
        enableButton.addTarget(self, action: #selector(enableButtonTap), for: .touchUpInside)
        enableButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            enableButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        actionButtonsStackView.addArrangedSubview(enableButton)
    }
    
    @objc func close() {
        output.close()
    }
    
    @objc func enableButtonTap() {
        let touchIdReason = biometricsAuthService.type == .faceID
            ? NSLocalizedString("auth_face_id_reason", comment: "")
            : NSLocalizedString("auth_touch_id_reason", comment: "")
        biometricsAuthService.authenticate(reason: touchIdReason, completion: output.enable)
    }
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        transitionCoordinator?.notifyWhenInteractionChanges({ [weak self] context in
            if !context.isCancelled {
                self?.output.dismissed()
            }
        })
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		let image = imageView.image
		
		imageView.image = image?.tintedImage(withColor: .Icons.iconAccent)
	}
}
