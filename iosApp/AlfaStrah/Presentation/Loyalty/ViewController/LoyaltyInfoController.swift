//
//  LoyaltyViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 5/14/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class LoyaltyInfoController: ViewController {
    struct Input {
        let accountId: String
        let alfaPoints: (_ useCache: Bool, _ completion: @escaping (Result<LoyaltyModel, AlfastrahError>) -> Void) -> Void
        let infoBlocks: (_ result: @escaping (Result<[LoyaltyBlock], AlfastrahError>) -> Void) -> Void
        let infoBlockLink: (_ blockId: Int, _ completion: @escaping (Result<String, AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let programDetails: () -> Void
        let promoAction: (NewsItemModel) -> Void
        let details: () -> Void
        let openURL: (_ url: String, _ fromViewController: UIViewController) -> Void
    }

    var input: Input!
    var output: Output!

    private var loyaltyNews: [ActionNewsItemModel] = []

	@IBOutlet private var bonusAccountCardView: CardView!
    @IBOutlet private var bonusAccountView: BonusAccountView!
    @IBOutlet private var newsStackView: UIStackView!
    @IBOutlet private var newsTitleLabel: UILabel!
	@IBOutlet private var loyaltyStatusCardView: CardView!
    @IBOutlet private var loyaltyStatusView: LoyaltyStatusView!
    @IBOutlet private var bottomGradientView: GradientView!
    @IBOutlet private var bottomGradientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var loadingIndicator: ActivityIndicatorView!
    @IBOutlet private var loadingIndicatorStackView: UIStackView!

    @IBOutlet private var newsTitleLabelView: UIView!
    @IBOutlet private var blocksStackView: UIStackView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private lazy var errorTitleLabel: UILabel = {
        let value = UILabel()
        value <~ Style.Label.primaryHeadline1
        value.text = NSLocalizedString("info_block_parcing_error", comment: "")
        return value
    }()

    private lazy var errorDiscriptionLabel: UILabel = {
        let value = UILabel()
        value <~ Style.Label.secondaryText
        value.numberOfLines = 0
        value.textAlignment = .center
        return value
    }()

    private lazy var errorStackView: UIStackView = {
        let value = UIStackView()
        value.axis = .vertical
        value.alignment = .center
        value.isHidden = true
        return value
    }()

    private lazy var retryButton: UIButton = {
        let value = UIButton()
        value <~ Style.Button.RedLinkButton(title: NSLocalizedString("info_block_retry_button_title", comment: ""))
        value.addTarget(self, action: #selector(getInfoBlocks), for: .touchUpInside)
        return value
    }()

    private func setupUI() {
        title = NSLocalizedString("alfa_points_title", comment: "")
		bonusAccountCardView.contentColor = .Background.backgroundSecondary
		bonusAccountCardView.highlightedColor = .Background.backgroundSecondary
		loyaltyStatusCardView.contentColor = .Background.backgroundSecondary
		loyaltyStatusCardView.highlightedColor = .Background.backgroundSecondary
		view.backgroundColor = .Background.backgroundContent
        newsTitleLabel <~ Style.Label.primaryHeadline1
        newsTitleLabel.text = NSLocalizedString("alfa_points_news_title", comment: "")
        addZeroView()
        refresh(useCache: true)
        bonusAccountView.output = .init(
            programDetails: output.programDetails,
            details: output.details
        )

        loadingIndicator.animating = true
        newsTitleLabelView.isHidden = true

        newsStackView.addArrangedSubview(errorStackView)
        newsStackView.addArrangedSubview(blocksStackView)

        errorStackView.translatesAutoresizingMaskIntoConstraints = false
        errorStackView.addArrangedSubview(errorTitleLabel)
        errorStackView.setCustomSpacing(12, after: errorTitleLabel)
        errorStackView.addArrangedSubview(errorDiscriptionLabel)
        errorStackView.setCustomSpacing(18, after: errorDiscriptionLabel)
        errorStackView.addArrangedSubview(retryButton)

        scrollView.contentInset.bottom = bottomGradientViewHeightConstraint.constant
		
		setupBottomGradientView()
    }
	
	private func setupBottomGradientView() {
		bottomGradientView.startPoint = CGPoint(x: 0.5, y: 0)
		bottomGradientView.endPoint = CGPoint(x: 0.5, y: 1)

		bottomGradientView.startColor = .Background.backgroundContent.withAlphaComponent(0)
		bottomGradientView.endColor = .Background.backgroundContent
		bottomGradientView.update()
	}

    private func refresh(useCache: Bool) {
        guard isViewLoaded else { return }

        zeroView?.update(viewModel: .init(kind: .loading))
        showZeroView()
        input.alfaPoints(false) { [weak self] result in
            guard let self = self else { return }

            self.updateData(result)
        }
        getInfoBlocks()
    }

    private func updateData(_ data: Result<LoyaltyModel, AlfastrahError>) {
        switch data {
            case .success(let points):
                hideZeroView()
                bonusAccountView.input = .init(
                    accountId: input.accountId,
                    alfaPoints: points
                )
                loyaltyStatusView.configure(loyaltyModel: points)
            case .failure(let error):
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.refresh(useCache: false) }))
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
                processError(error)
        }
    }

    @objc func getInfoBlocks() {
        loadingIndicatorStackView.isHidden = false
        errorStackView.isHidden = true

        input.infoBlocks { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let data):
                    self.createBlocks(from: data)

                case .failure(let error):
                    self.showErrorStack(with: error.displayValue)
            }
            self.loadingIndicatorStackView.isHidden = true
        }
    }

    private func createBlocks(from data: [LoyaltyBlock]) {
        blocksStackView.subviews.forEach { $0.removeFromSuperview() }
        self.errorStackView.isHidden = true
        self.newsTitleLabelView.isHidden = false

        data.forEach { block in
            let item = ActionNewsItemModel(
                title: block.title,
                info: block.description,
                actionTitle: NSLocalizedString("common_checkout", comment: ""),
                iconImageURL: block.imageUrl
            ) { controller in
                self.input.infoBlockLink(block.id) { completion in
                    switch completion {
                        case .success(let url):
                            self.output.openURL(url, controller)
                        case .failure(let error):
                            self.processError(error)
                    }
                }
            }
            let promoView = MainPromoItem.fromNib()
            self.container?.resolve(promoView)
            promoView.set(
                input: .init(model: item),
                action: self.output.promoAction
            )
            self.blocksStackView.addArrangedSubview(CardView(contentView: promoView))
        }
    }

    private func showErrorStack(with error: String?) {
        errorDiscriptionLabel.text = error
        errorStackView.isHidden = false
        newsTitleLabelView.isHidden = true
        blocksStackView.isHidden = true
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		bottomGradientView.startColor = .Background.backgroundContent.withAlphaComponent(0)
		bottomGradientView.endColor = .Background.backgroundContent
		bottomGradientView.update()
	}
}
