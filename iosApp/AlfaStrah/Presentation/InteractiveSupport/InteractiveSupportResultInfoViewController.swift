//
//  InteractiveSupportResultInfoViewController.swift
//  AlfaStrah
//
//  Created by vit on 22.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints
import SDWebImage

class InteractiveSupportResultInfoViewController: ViewController,
                                                  TranslucentNavigationViewControllerDelegate {
    struct Input {
        let isLastResult: Bool
        let result: InteractiveSupportQuestionnaireResult
    }
    
    struct Output {
        let primaryAction: () -> Void
        let navigationAction: () -> Void
    }

    var input: Input!
    var output: Output!
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let actionButtonsStackView = UIStackView()
    
    private let actionButton = RoundEdgeButton()
    private let imageView = UIImageView()
    private let infoStackView = UIStackView()
    
    private let titleLabel = UILabel()
	private let gradientOverlayImageView = UIImageView()
    
    private lazy var imageViewHeightConstraint: NSLayoutConstraint = {
        return imageView.height(0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
    }
    
    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
        
        navigationController?.navigationBar.isTranslucent = false
        
        setupRightNavigationBar()
        
        setupScrollView()
        setupContentStackView()
        setupActionButtonStackView()
        setupActionButton()
        setupImageView()
        
        setupInfoStackView()
		
		setupGradientOverlay()
    }
	
	private func setupGradientOverlay() {
		imageView.addSubview(gradientOverlayImageView)
		gradientOverlayImageView.edgesToSuperview(excluding: .top)
		gradientOverlayImageView.height(Constants.imageGradientOverlayHeight)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		updateStepsColor()
		updateGradientOverlay()
	}
        
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        contentStackView.addArrangedSubview(imageView)
        
        imageView.width(to: view)
        imageViewHeightConstraint.constant = calculateImageViewHeight(from: Constants.infoPlaceholderImage)
        imageViewHeightConstraint.isActive = true
        
        imageView.sd_imageTransition = .fade(duration: 0.2)
        imageView.sd_setImage(
            with: nil,
            placeholderImage: Constants.infoPlaceholderImage
		)
    }
    
    private func calculateImageViewHeight(from image: UIImage) -> CGFloat {
        return image.size.height * (UIScreen.main.bounds.width / image.size.width)
    }
    
    private func setupScrollView() {
        scrollView.alwaysBounceVertical = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(scrollView)
        
        scrollView.edgesToSuperview(excluding: .top)
        scrollView.topToSuperview(offset: -(navigationController?.navigationBar.frame.height ?? 0))
    }
    
    private func setupActionButtonStackView() {
        view.addSubview(actionButtonsStackView)
        
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 18, right: 18)
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = 0
        actionButtonsStackView.backgroundColor = .clear
        
        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        actionButtonsStackView.edgesToSuperview(excluding: .top)
    }
    
    private func setupInfoStackView() {
        infoStackView.isLayoutMarginsRelativeArrangement = true
        infoStackView.layoutMargins = UIEdgeInsets(top: 21, left: 18, bottom: 132, right: 18)
        infoStackView.alignment = .fill
        infoStackView.distribution = .fill
        infoStackView.axis = .vertical
        infoStackView.spacing = 15
        infoStackView.backgroundColor = .clear
        
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(infoStackView)
        
        setupTitleLabel()

        if let content = input.result.content {
            for contentResult in content {
                switch contentResult.contentType {
                    case .text(let string):
                        titleLabel.text = string
                        
                    case .image(url: let url):
                        imageView.sd_setImage(
                            with: url,
                            placeholderImage: Constants.infoPlaceholderImage,
                            completed: { [weak self] image, err, _, _ in
                                guard let self
                                else { return }
                                
                                if let image, err == nil {
                                    self.imageViewHeightConstraint.constant = self.calculateImageViewHeight(from: image)
                                }
                            }
                        )
                    case .answers(let answers):
                        setupAnswersSecion(answers)
                    case .steps(let steps):
                        setupStepsSection(steps)
                    default:
                        break
                }
            }
        }
    }
    
    private func setupTitleLabel() {
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.numberOfLines = 0
        
        infoStackView.addArrangedSubview(titleLabel)
    }
        
    private func setupAnswersSecion(_ answers: [InteractiveSupportQuestionnaireResultContent.Answer] ) {
        func createRow(left: String, right: String) -> UIStackView {
            let leftLabel = UILabel() <~ Style.Label.secondaryText
            leftLabel.numberOfLines = 0
            leftLabel.textAlignment = .left
            leftLabel.text = left
            
            let rightLabel = UILabel() <~ Style.Label.primaryText
            rightLabel.numberOfLines = 0
            rightLabel.textAlignment = .right
            rightLabel.text = right
            
            let rowStackView = UIStackView(arrangedSubviews: [leftLabel, rightLabel])
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.axis = .horizontal
            rowStackView.spacing = 6
            rowStackView.backgroundColor = .clear
            
            return rowStackView
        }
        
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = insets(18)
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 9
		stackView.backgroundColor = .Background.backgroundSecondary
                
        for answer in answers {
            let row = createRow(left: answer.title, right: answer.value)
            stackView.addArrangedSubview(row)
        }
        
        infoStackView.addArrangedSubview(stackView.embedded(hasShadow: true))
    }
	
	private var imageViewToThemedValue: [UIImageView: ThemedValue] = [:]
	
	private func updateStepsColor() {
		imageViewToThemedValue.forEach {
			let imageThemedURL = $0.value.url(for: traitCollection.userInterfaceStyle)
			
			$0.key.sd_setImage(
				with: imageThemedURL,
				placeholderImage: nil
			)
		}
	}
    
    private func setupStepsSection(_ steps: [InteractiveSupportQuestionnaireResultContent.Step]) {
        let containerView = UIView()
		containerView.backgroundColor = .Background.backgroundSecondary
        
        let title = UILabel() <~ Style.Label.primaryHeadline1
        title.text = NSLocalizedString("interactive_support_questionaire_info_steps_title", comment: "")
        
        containerView.addSubview(title)
        title.edgesToSuperview(excluding: .bottom, insets: insets(18))
        
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 0
        
        containerView.addSubview(stackView)
        
        stackView.topToBottom(of: title, offset: 15)
        stackView.edgesToSuperview(excluding: .top, insets: insets(18))
		
		func createStep(with imageUrl: URL, imageThemed: ThemedValue?, and text: String) -> UIStackView {
            let stackView = UIStackView()
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.axis = .vertical
            stackView.spacing = 3

            let imageViewContainer = UIView()
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            
            imageViewContainer.addSubview(imageView)
            
            stackView.addArrangedSubview(imageViewContainer)
            imageView.width(50)
            imageView.heightToWidth(of: imageView)
            imageView.edgesToSuperview()
            
            let description = UILabel() <~ Style.Label.primaryCaption1
            description.numberOfLines = 0
            description.textAlignment = .center
            description.text = text
            stackView.addArrangedSubview(description)

            imageView.sd_setImage(
                with: imageUrl,
                placeholderImage: nil
            )
			
			if let imageThemed {
				imageViewToThemedValue[imageView] = imageThemed
			}
            
            return stackView
        }
        
        for step in steps {
			let column = createStep(with: step.image, imageThemed: step.imageThemed, and: step.text)
            stackView.addArrangedSubview(column)
        }
        
        infoStackView.addArrangedSubview(containerView.embedded(hasShadow: true))
    }
    
    private func setupContentStackView() {
        scrollView.addSubview(contentStackView)
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .zero
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
        contentStackView.backgroundColor = .clear
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.edgesToSuperview()
        contentStackView.width(to: view)
    }
    
    private func setupRightNavigationBar() {
        let button = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(rightBarButtonItemActionTap(_:)))
        
        let buttonTitle = input.isLastResult
            ? NSLocalizedString("common_quit", comment: "")
            : NSLocalizedString("common_skip_button", comment: "")
        
        button <~ Style.Button.NavigationItemRed(title: buttonTitle)
        
        navigationItem.rightBarButtonItem = button
    }
    
    private func setupActionButton() {
		guard let buttonConfiguration = input.result.button
		else {
			actionButton.isHidden = true
			return
		}
		
		actionButton.isHidden = false

		let textColor = buttonConfiguration.textHexColorThemed?.color(for: traitCollection.userInterfaceStyle)
		?? .from(hex: buttonConfiguration.textHexColor)
		let backgroundColor = buttonConfiguration.backgroundHexColorThemed?.color(for: traitCollection.userInterfaceStyle)
		?? .from(hex: buttonConfiguration.backgroundHexColor)
		
		if let textColor, let backgroundColor {
			actionButton <~ Style.RoundedButton.RoundedParameterizedButton(
				textColor: textColor,
				backgroundColor: backgroundColor
			)
		} else {
			actionButton <~ Style.RoundedButton.redParameterizedButton
		}

        actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)

		actionButton.setTitle(
			buttonConfiguration.action.title,
			for: .normal
		)

        actionButton.height(48)
        
        actionButtonsStackView.addArrangedSubview(actionButton)
    }
    
    @objc func actionButtonTap() {
        output.primaryAction()
    }

    @objc private func rightBarButtonItemActionTap(_ sender: UIButton) {
        output.navigationAction()
    }
    
    // MARK: - GradientNavigationViewControllerDelegate
    func backgroundType() -> TranslucentNavigationController.BackgroundType {
        .gradient
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateGradientOverlay()
		setupActionButton()
		updateStepsColor()
	}
	
	private func updateGradientOverlay() {
		gradientOverlayImageView.image = UIImage.gradientImage(
			from: .Other.imageGradient.withAlphaComponent(0),
			to: .Other.imageGradient,
			with: gradientOverlayImageView.frame
		)
	}
    
    struct Constants {
        static let infoPlaceholderImage = UIImage(named: "image-placeholder-result-info-375x218") ?? UIImage()
		static let stepPlaceholderImage = UIImage.Icons.placeholder
		static let imageGradientOverlayHeight: CGFloat = 87
    }
}
