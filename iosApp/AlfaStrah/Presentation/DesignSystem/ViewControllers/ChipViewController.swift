//
//  ChipViewController.swift
//  AlfaStrah
//
//  Created by Darya Viter on 16.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class ChipViewController: ViewController {
    struct Input {
        let title: String
    }

    var input: Input!

    private let scrollView: UIScrollView = .init()
    private let scrollContentView: UIView = .init()
    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = input.title
        view.backgroundColor = Style.Color.background

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(rootStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: scrollView, in: view) +
                NSLayoutConstraint.fill(view: scrollContentView, in: scrollView) +
                NSLayoutConstraint.fill(view: rootStackView, in: scrollContentView, margins: Style.Margins.defaultInsets) +
                [ scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor) ]
        )

        let enableChipView = ChipView()
        enableChipView.setTitle("EnableChipView", for: .normal)
        let disableChipView = ChipView()
        disableChipView.isEnabled = false
        disableChipView.setTitle("DisableChipView", for: .normal)
        let preselectedChipView = ChipView()
        preselectedChipView.setTitle("PreselectedChipView", for: .normal)
        preselectedChipView.isSelected = true

        rootStackView.addArrangedSubview(enableChipView)
        rootStackView.addArrangedSubview(disableChipView)
        rootStackView.addArrangedSubview(preselectedChipView)
    }
}
