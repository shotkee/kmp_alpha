//
//  PincodeViewController.swift
//  AlfaStrah
//
//  Created by vit on 22.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class CreatePincodeViewController: ViewController {
    private let primaryContainerStackView = UIStackView()
    private let secondaryContainerStackView = UIStackView()
    
    private let pincodeKeyboardView = PincodeKeyboardView()
    
    struct Input {
        let showExitButton: Bool
    }
    
    struct Output {
        let close: () -> Void
        let codeConfirmed: (String) -> Void
    }
    
    var input: Input!
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if input.showExitButton {
            navigationItem.setHidesBackButton(true, animated: true)
        }
        
        title = NSLocalizedString("create_pincode_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
        
        setupPrimaryContainerStackView()
        setupSecondaryActionTitleLabel()
        setupPincodeKeyboardView()
    }
    
    private func setupPincodeKeyboardView() {
        view.addSubview(pincodeKeyboardView)
        
        pincodeKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pincodeKeyboardView.topAnchor.constraint(equalTo: primaryContainerStackView.bottomAnchor),
            pincodeKeyboardView.widthAnchor.constraint(equalToConstant: 232),
            pincodeKeyboardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pincodeKeyboardView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        pincodeKeyboardView.showExitButton = input.showExitButton
        pincodeKeyboardView.keysInputCompletion = { [weak self] result in
            guard let self = self
            else { return }
            
            switch result {
                case .success(let code):
                    if let code = self.pincodeKeyboardView.initialSequence {
                        self.output.codeConfirmed(code)
                    } else {
                        self.pincodeKeyboardView.initialSequence = code
                        self.confirmCodeAnimation()
                    }
                case .failure:
                    self.pincodeKeyboardView.initialSequence = nil
                    self.reverseAnimation()
            }
        }
        pincodeKeyboardView.close = { [weak self] in
            self?.output.close()
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
    
    private func reverseAnimation() {
        UIView.animate(withDuration: 0.5, animations: { [ weak self ] in
            guard let self = self
            else { return }
            
            self.primaryContainerStackView.alpha = 1
            self.secondaryContainerStackView.alpha = 0
            
            self.primaryContainerStackView.transform = .identity
            self.secondaryContainerStackView.transform = self.secondaryContainerStackView.transform.translatedBy(x: Constants.screenWidth, y: 0)
        })
    }
    
    private func setupPrimaryContainerStackView() {
        view.addSubview(primaryContainerStackView)

        primaryContainerStackView.isLayoutMarginsRelativeArrangement = true
        primaryContainerStackView.layoutMargins = .zero
        primaryContainerStackView.alignment = .fill
        primaryContainerStackView.distribution = .fill
        primaryContainerStackView.axis = .vertical
        primaryContainerStackView.spacing = 9
        primaryContainerStackView.backgroundColor = .clear

        primaryContainerStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            primaryContainerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            primaryContainerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            primaryContainerStackView.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 172)
        ])
        
        let titleLabel = UILabel()
        
        titleLabel.text = NSLocalizedString("auth_create_pincode_title", comment: "")
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        titleLabel <~ Style.Label.primaryHeadline2
        
        primaryContainerStackView.addArrangedSubview(titleLabel)
        
        let descriptionLabel = UILabel()
                
        descriptionLabel.text = NSLocalizedString("auth_create_pincode_description", comment: "")
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        descriptionLabel <~ Style.Label.secondaryText
        
        primaryContainerStackView.addArrangedSubview(descriptionLabel)
    }
        
    private func setupSecondaryActionTitleLabel() {
        view.addSubview(secondaryContainerStackView)
        
        secondaryContainerStackView.alpha = 0

        secondaryContainerStackView.isLayoutMarginsRelativeArrangement = true
        secondaryContainerStackView.layoutMargins = .zero
        secondaryContainerStackView.alignment = .fill
        secondaryContainerStackView.distribution = .fill
        secondaryContainerStackView.axis = .vertical
        secondaryContainerStackView.spacing = 9
        secondaryContainerStackView.backgroundColor = .clear

        secondaryContainerStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            secondaryContainerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            secondaryContainerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            secondaryContainerStackView.bottomAnchor.constraint(equalTo: primaryContainerStackView.bottomAnchor)
            // fix iphone 7 top anchor safeArea wrong space
        ])
        
        let titleLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = NSLocalizedString("auth_reenter_pincode_title", comment: "")
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        titleLabel <~ Style.Label.primaryHeadline2
        
        secondaryContainerStackView.addArrangedSubview(titleLabel)
    }
    
    struct Constants {
        static let screenWidth = UIScreen.main.bounds.width
    }
}
