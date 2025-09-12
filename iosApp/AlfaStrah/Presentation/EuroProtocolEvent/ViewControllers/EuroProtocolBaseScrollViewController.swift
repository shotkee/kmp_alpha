//
//  EuroProtocolBaseScrollViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 23.08.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class EuroProtocolBaseScrollViewController: EuroProtocolBaseViewController {
    lazy var scrollView: UIScrollView = .init()
    lazy var scrollContentView: UIView = .init()

    private lazy var bottomButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 9
        stack.distribution = .fill
        return stack
    }()

    private lazy var gradientView: GradientView = {
        var value: GradientView = .init(frame: .zero)
        value.startPoint = CGPoint(x: 0.5, y: 0)
        value.endPoint = CGPoint(x: 0.5, y: 1)

		value.startColor = .Background.backgroundContent.withAlphaComponent(0)
		value.endColor = .Background.backgroundContent
        value.update()
        return value
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: gradientView.frame.height, right: 0)
    }

    func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(bottomButtonsStackView)
        view.addSubview(gradientView)
        scrollView.addSubview(scrollContentView)

        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomButtonsStackView.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.widthAnchor.constraint(equalToConstant: view.bounds.width),

            bottomButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            bottomButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            bottomButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            gradientView.bottomAnchor.constraint(equalTo: bottomButtonsStackView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func addBottomButtonsContent(_ view: UIView) {
        bottomButtonsStackView.addArrangedSubview(view)
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		gradientView.startColor = .Background.backgroundContent.withAlphaComponent(0)
		gradientView.endColor = .Background.backgroundContent
		gradientView.update()
	}
}
