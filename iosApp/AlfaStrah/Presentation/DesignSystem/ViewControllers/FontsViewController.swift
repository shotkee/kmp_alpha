//
//  FontsViewController.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 31.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//
import UIKit

class FontsViewController: ViewController {
    private let rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 9
        return stack
    }()

    private var scrollView: UIScrollView = .init()
    private var scrollContentView: UIView = .init()

    struct Input {
        let title: String
    }

    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(rootStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: scrollView, in: view) +
            NSLayoutConstraint.fill(view: scrollContentView, in: scrollView) +
            NSLayoutConstraint.fill(view: rootStackView, in: scrollView, margins: Style.Margins.defaultInsets) +
            [ scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor) ]
        )
    }

    private func setupUI() {
        title = input.title
        view.backgroundColor = Style.Color.background

        let fontNamesLabel = UILabel()
        fontNamesLabel.lineBreakMode = .byWordWrapping
        fontNamesLabel.numberOfLines = 0
        fontNamesLabel.text = """
             Used fonts:
             KievitPro, Regular, Book, Bold
             """
        fontNamesLabel <~ Style.Label.secondaryText
        rootStackView.addArrangedSubview(fontNamesLabel)

        DesignSystemFont.allFonts.forEach {
            let fontView = FontView()
            fontView.set(font: $0)
            rootStackView.addArrangedSubview(fontView)
            rootStackView.addArrangedSubview(spacer(6))
        }
    }
}
