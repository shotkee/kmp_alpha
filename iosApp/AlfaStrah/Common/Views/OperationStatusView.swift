//
//  OperationStatusView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/31/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy 

class OperationStatusView: UIView {
    enum ButtonsAlignment {
        case center
        case bottom
    }
    
    enum ButtonsAxis {
        case vertical
        case horizontal
    }
    
    private var buttonsBottomConstraints: [NSLayoutConstraint]?
    private var buttonsCenterConstraints: [NSLayoutConstraint]?
    
    struct StateInfo {
        let title: String
        let description: String?
        let icon: UIImage?
		let iconTintColor: UIColor = .Icons.iconAccent
        
        var buttonsAlignment: ButtonsAlignment
        var buttonsAxis: ButtonsAxis
        
        init(
            title: String,
            description: String?,
            icon: UIImage?,
            buttonsAlignment: ButtonsAlignment = .bottom,
            buttonsAxis: ButtonsAxis = .vertical
        ) {
            self.title = title
            self.description = description
			self.icon = icon
            self.buttonsAlignment = buttonsAlignment
            self.buttonsAxis = buttonsAxis
        }
    }
    
    struct Notify {
        let updateState: (_ state: State) -> Void
        let buttonConfiguration: ([ButtonConfiguration]) -> Void
        let addCustomViews: ([UIView]) -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify: Notify = Notify(
        updateState: { [weak self] state in
            self?.updateState(state)
        },
        buttonConfiguration: { [weak self] buttonConfiguration in
            self?.configure(buttonConfiguration: buttonConfiguration)
        },
        addCustomViews: { [weak self] views in
            self?.configure(with: views)
        }
    )

    enum State {
        case info(StateInfo)
        case loading(StateInfo)
    }
        
    class ButtonConfiguration: NSObject {
        private let action: () -> Void
        let title: String
        let widthButton: CGFloat
        let style: Style.RoundedButton.ColoredButton
        var height: CGFloat
        
        init(
            title: String,
            style: Style.RoundedButton.ColoredButton,
            height: CGFloat = 48.0,
            widthButton: CGFloat = UIScreen.main.bounds.width - 36,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.widthButton = widthButton
            self.style = style
            self.height = height
            self.action = action

            super.init()
        }

        convenience init(
            title: String,
            height: CGFloat = 48.0,
            widthButton: CGFloat = UIScreen.main.bounds.width - 36,
            isPrimary: Bool,
            action: @escaping () -> Void
        ) {
            self.init(
                title: title,
                style: isPrimary
                    ? Style.RoundedButton.primaryButtonLarge
                    : Style.RoundedButton.outlinedButtonLarge,
                height: height,
                widthButton: widthButton,
                action: action
            )
        }

        @objc func tapAction(_ sender: UIButton) {
            action()
        }

        static let mainScreenOtChat: [ButtonConfiguration] = [
            ButtonConfiguration(
                title: NSLocalizedString("common_to_main_screen", comment: ""),
                isPrimary: false,
                action: { ApplicationFlow.shared.show(item: .tabBar(.home)) }
            ),
            ButtonConfiguration(
                title: NSLocalizedString("common_write_to_chat", comment: ""),
                isPrimary: true,
                action: { ApplicationFlow.shared.show(item: .tabBar(.chat)) }
            )
        ]

        static let settings: [ButtonConfiguration] = [
            ButtonConfiguration(
                title: NSLocalizedString("common_open_settings", comment: ""),
                isPrimary: true,
                action: { ApplicationFlow.shared.show(item: .settings) }
            )
        ]

        static func retry(isPrimary: Bool = true, action: @escaping () -> Void) -> ButtonConfiguration {
            ButtonConfiguration(
                title: NSLocalizedString("common_retry", comment: ""),
                isPrimary: true,
                action: action
            )
        }
    }

    private var imageView: UIImageView?
    private var titleLabel: UILabel?
    private var infoLabel: UILabel?
	private lazy var indicatorView: ModalActivityIndicatorView = {
		let indicatorView: ModalActivityIndicatorView = .fromNib()
		self.indicatorView = indicatorView
		indicatorView.clearIndicatorBackground()
		indicatorView.animating = false
		indicatorView.translatesAutoresizingMaskIntoConstraints = false
		indicatorView.isHidden = true
		addSubview(indicatorView)
		
		NSLayoutConstraint.activate(
			NSLayoutConstraint.fill(view: indicatorView, in: self)
		)
		return indicatorView
	}()
	
    private var buttonsStackView: UIStackView?
    private var buttonConfiguration: [ButtonConfiguration] = []
    private var state: State?
    private var containerView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    func setupUI() {
        backgroundColor = .Background.backgroundContent
        let imageView = UIImageView()
        self.imageView = imageView
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel <~ Style.Label.primaryHeadline2
        self.titleLabel = titleLabel
        let infoLabel = UILabel()
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel <~ Style.Label.secondaryText
        self.infoLabel = infoLabel
        let containerView = UIView()
        self.containerView = containerView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(infoLabel)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        let stackView = UIStackView()
        buttonsStackView = stackView
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 9
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
		
		NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -28),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -9),
                infoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -28),
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
                stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ]
        )
        
        buttonsBottomConstraints = [
            stackView.topAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: 18),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ]
        
        buttonsCenterConstraints = [
            stackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 36),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ]
        
        set(buttonsAlignment: .bottom)
        
        state.map { self.updateState($0) }
        configure(buttonConfiguration: buttonConfiguration)
    }

    private func updateState(_ state: State) {
        self.state = state

        switch state {
            case .info(let stateInfo):
                indicatorView.animating = false
                indicatorView.isHidden = true
				
				if let image = stateInfo.icon {
					switch image.renderingMode {
						case .automatic, .alwaysOriginal:
							imageView?.image = stateInfo.icon
						case .alwaysTemplate:
							imageView?.image = stateInfo.icon?.tintedImage(withColor: stateInfo.iconTintColor)
						default:
							imageView?.image = stateInfo.icon
					}
				}
				
				titleLabel?.text = stateInfo.title
                infoLabel?.text = stateInfo.description
                
                set(buttonsAlignment: stateInfo.buttonsAlignment)
                set(buttonsAxis: stateInfo.buttonsAxis)
                
            case .loading(let stateInfo):
                indicatorView.isHidden = false
                indicatorView.animating = true
                indicatorView.infoString = stateInfo.title
                
        }
    }
    
    private func configure(buttonConfiguration: [ButtonConfiguration]) {
        guard let buttonsStackView = buttonsStackView
        else { return }
        
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.buttonConfiguration = buttonConfiguration

        if !buttonConfiguration.isEmpty {
            for configuration in buttonConfiguration {
                let button = RoundEdgeButton(type: .custom)
                button.setTitle(configuration.title, for: .normal)
                button.addTarget(configuration, action: #selector(configuration.tapAction(_: )), for: .touchUpInside)
                button <~ configuration.style
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(
                    equalToConstant: 48
                ).isActive = true
                button.widthAnchor.constraint(
                    equalToConstant: configuration.widthButton
                ).isActive = true
                buttonsStackView.addArrangedSubview(button)
            }
        }
    }
    
    private func configure(with views: [UIView]) {
        guard let buttonsStackView = buttonsStackView
        else { return }
        
        buttonsStackView.subviews.forEach { $0.removeFromSuperview() }
        
        for view in views {
            buttonsStackView.addArrangedSubview(view)
        }
    }
    
    private func set(buttonsAlignment: ButtonsAlignment) {
        guard let buttonsCenterConstraints = self.buttonsCenterConstraints,
              let buttonsBottomConstraints = self.buttonsBottomConstraints
        else { return }
        
        switch buttonsAlignment {
            case .bottom:
                NSLayoutConstraint.deactivate(buttonsCenterConstraints)
                NSLayoutConstraint.activate(buttonsBottomConstraints)
            case .center:
                NSLayoutConstraint.deactivate(buttonsBottomConstraints)
                NSLayoutConstraint.activate(buttonsCenterConstraints)
        }
    }
    
    private func set(buttonsAxis: ButtonsAxis) {
        if buttonsAxis == .vertical {
            buttonsStackView?.axis = .vertical
            
            buttonsStackView?.distribution = .equalSpacing
            buttonsStackView?.spacing = 9
        } else {
            buttonsStackView?.axis = .horizontal
            
            buttonsStackView?.distribution = .fillEqually
            buttonsStackView?.spacing = 15
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		guard let state
		else { return }
		
		updateState(state)
	}
}
