//
//  SosActivitiesViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class SosActivitiesViewController: ViewController {
    struct Input {
		var isDemoMode: Bool
        var isAuthorized: () -> Bool
        var sosModel: SosModel
		var checkOsagoBlock: CheckOsagoBlock?
    }

    struct Output {
		var demo: () -> Void
        var chat: () -> Void
        var instructions: () -> Void
        var sosActivity: (SosActivityModel) -> Void
		var checkRSABottomSheet: ((CheckOsagoBlock) -> Void)?
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var insurancesCountLabel: UILabel!
    @IBOutlet private var smallCardsStackView: UIStackView!
    @IBOutlet private var largeCardsStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		
        title = input.sosModel.title

        scrollView.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 0)
        insurancesCountLabel.textAlignment = .center
        insurancesCountLabel <~ Style.Label.accentText
        updateUI()
    }

    private func updateUI() {
        smallCardsStackView.subviews.forEach { $0.removeFromSuperview() }
        largeCardsStackView.subviews.forEach { $0.removeFromSuperview() }

        let format = NSLocalizedString("insurance_filter_count", comment: "")
        insurancesCountLabel.text = String.localizedStringWithFormat(
            format,
            input.isAuthorized()
                ? input.sosModel.insuranceCount
                : 0
        )

        let chatActionView = SosActionView.fromNib()
        chatActionView.set(
            title: NSLocalizedString("sos_open_chat", comment: ""),
            icon: UIImage(named: "icon-sos-action-chat")
        ) { [weak self] in
            self?.output.chat()
        }

        let instructionsActionView = SosActionView.fromNib()
        instructionsActionView.set(
            title: NSLocalizedString("sos_open_instructions", comment: ""),
            icon: UIImage(named: "icon-sos-action-instructions")
        ) { [weak self] in
            guard let self = self else { return }

            if self.input.sosModel.kind == .category {
                switch self.input.sosModel.insuranceCategory?.type {
                    case .auto?:
                        self.analytics.track(event: AnalyticsEvent.SOS.sosAutoInstructions)
                    case .health?:
                        self.analytics.track(event: AnalyticsEvent.SOS.sosHealthInstructions)
                    case .property?:
                        self.analytics.track(event: AnalyticsEvent.SOS.sosPropertyInstructions)
                    case .travel?:
                        self.analytics.track(event: AnalyticsEvent.SOS.sosTripInstructions)
                    case .passengers?:
                        self.analytics.track(event: AnalyticsEvent.SOS.sosPassengersInstructions)
                    case .life?, .unsupported?, nil:
                        break
                }
            }
            self.output.instructions()
        }

        switch self.input.sosModel.insuranceCategory?.type {
            case .auto?, .property?, .travel?, .passengers?, .life?, .unsupported?, nil:
                smallCardsStackView.addArrangedSubview(CardView(contentView: chatActionView))
                smallCardsStackView.addArrangedSubview(CardView(contentView: instructionsActionView))
            case .health?:
                smallCardsStackView.addArrangedSubview(CardView(contentView: instructionsActionView))
        }

        for sosActivity in input.sosModel.sosActivityList where sosActivity.isSupported {
            var actionAvailable = true
            if !input.isAuthorized() && sosActivity.kind == .onWebsite {
                continue
            }
            if sosActivity.kind == .voipCall,
               !sosActivity.sosPhoneList.contains(where: { $0.voipCall != nil }) {
                actionAvailable = false
            }
			
			var actionSosLifeAvailable = false
			if sosActivity.kind == .life || sosActivity.kind == .onlinePayment {
				actionSosLifeAvailable = input.sosModel.isActive
			}
			
            let sosInfoView = SosInfoView.fromNib()
			
			sosInfoView.backgroundColor = .Background.backgroundSecondary
			
            sosInfoView.set(
                mode: .info,
                title: sosActivity.title,
                description: sosActivity.description,
                icon: InsuranceHelper.image(for: sosActivity.kind),
				overlay: InsuranceHelper.overlayForImage(for: sosActivity.kind),
                isActive: (sosActivity.isActive || actionSosLifeAvailable) && actionAvailable
            ) { [weak self] in
				
				guard let self
				else { return }
				
                if actionAvailable {
                    self.output.sosActivity(sosActivity)
                }
				else if sosActivity.kind == .voipCall,
						self.input.isDemoMode
				{
					self.output.demo()
				}
            }

            let cardView = CardView(contentView: sosInfoView)
            largeCardsStackView.addArrangedSubview(cardView)
        }
		
		if let checkOsagoBlock = input.checkOsagoBlock
		{
			largeCardsStackView.addArrangedSubview(
				createSpacerView()
			)
			
			largeCardsStackView.addArrangedSubview(
				createRSAView(checkOsagoBlock: checkOsagoBlock)
			)
		}
    }
	
	private func createSpacerView() -> UIView
	{
		let view = UIView()
		view.height(1)
		view.backgroundColor = .Stroke.divider
		
		return view
	}
	
	private func createRSAView(checkOsagoBlock: CheckOsagoBlock) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .Background.backgroundSecondary
		
		// stackView
		let stackView = createStackView()
		view.addSubview(stackView)
		stackView.edgesToSuperview(
			insets: .init(
				top: 20,
				left: 15,
				bottom: 20,
				right: 15
			)
		)
		
		stackView.addArrangedSubview(
			createNameLabel(title: checkOsagoBlock.firstTitle)
		)
		
		let descriptionLabel = createDescriptionLabel(
			description: checkOsagoBlock.firstDescription
		)
		
		stackView.addArrangedSubview(
			descriptionLabel
		)
		
		stackView.setCustomSpacing(15, after: descriptionLabel)
		stackView.addArrangedSubview(
			createCheckButton(title: checkOsagoBlock.firstButtonText)
		)
		
		return CardView(contentView: view)
	}
	
	private func createStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 5
		
		return stackView
	}
	
	private func createNameLabel(title: String) -> UILabel
	{
		let nameLabel = UILabel()
		nameLabel.text = title
		nameLabel.numberOfLines = 1
		nameLabel <~ Style.Label.primaryText
		
		return nameLabel
	}
	
	private func createDescriptionLabel(description: String) -> UILabel
	{
		let descriptionLabel = UILabel()
		descriptionLabel.text = description
		descriptionLabel.numberOfLines = 0
		descriptionLabel <~ Style.Label.secondarySubhead
		
		return descriptionLabel
	}
	
	private func createCheckButton(title: String) -> RoundEdgeButton
	{
		let button = RoundEdgeButton()
		button <~ Style.RoundedButton.outlinedButtonSmall
		button.setTitle(title, for: .normal)
		button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
		
		return button
	}
	
	@objc private func onTap()
	{
		if let checkOsagoBlock = input.checkOsagoBlock
		{
			output.checkRSABottomSheet?(checkOsagoBlock)
		}
	}
}
