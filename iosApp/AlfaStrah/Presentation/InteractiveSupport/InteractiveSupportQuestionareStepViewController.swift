//
//  InteractiveSupportQuestionareStepViewController.swift
//  AlfaStrah
//
//  Created by vit on 21.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

class InteractiveSupportQuestionareStepViewController: ViewController {
    struct Item {
        let value: String
        let tapHandler: (Int) -> Void
    }

    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let rootStackView = UIStackView()
    private let titleLabel = UILabel()

    struct Input {
        let title: String
        let items: [Item]
    }

    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("interactive_support_title", comment: "")
        
        commonSetup()
        setupUI()
    }

	private func commonSetup() {
		view.backgroundColor = .Background.backgroundContent
        
        scrollView.backgroundColor = .clear
        scrollContentView.backgroundColor = .clear

        rootStackView.alignment = .fill
        rootStackView.axis = .vertical
        rootStackView.distribution = .fill
        rootStackView.spacing = 0
        rootStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.layoutMargins = UIEdgeInsets(top: 3, left: 18, bottom: 15, right: 18)

        view.addSubview(scrollView)
        scrollView.edgesToSuperview()
        
        scrollView.addSubview(scrollContentView)
        scrollContentView.edgesToSuperview()
        
        scrollContentView.addSubview(titleLabel)
        titleLabel.topToSuperview(offset: 21)
        titleLabel.leadingToSuperview(offset: 18)
        titleLabel.trailingToSuperview(offset: 18)
        
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.numberOfLines = 0
        
        scrollContentView.addSubview(rootStackView)
        rootStackView.topToBottom(of: titleLabel)
        rootStackView.leadingToSuperview()
        rootStackView.trailingToSuperview()
        rootStackView.bottomToSuperview()
        
        scrollContentView.width(to: view)
    }

    private func setupUI() {
        titleLabel.text = input.title
        
        for (index, item) in input.items.enumerated() {
            rootStackView.addArrangedSubview(spacer(12))

            let cardView = SmallValueCardView()
            cardView.set(
                title: "",
                placeholder: "",
                value: item.value,
                error: nil,
                icon: .rightArrow
            )
                        
            cardView.tapHandler = {
                item.tapHandler(index)
            }
            
			rootStackView.addArrangedSubview(CardView(contentView: cardView))
        }
    }
}
