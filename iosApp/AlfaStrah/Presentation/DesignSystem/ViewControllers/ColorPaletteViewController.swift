//
//  ColorPaletteViewController.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 24.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class ColorPaletteViewController: ViewController {
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private var rootStackView: UIStackView = .init()

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
        title = input.title
        view.backgroundColor = Style.Color.Palette.white
        scrollView.backgroundColor = .clear

        rootStackView.alignment = .fill
        rootStackView.axis = .vertical
        rootStackView.distribution = .fill
        rootStackView.spacing = 10

        view.addSubview(scrollView)
        scrollView.addSubview(rootStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: scrollView, in: view) +
                NSLayoutConstraint.fill(view: rootStackView, in: scrollView, margins: Style.Margins.defaultInsets) +
                [
                    view.widthAnchor.constraint(
                        equalTo: rootStackView.widthAnchor,
                        constant: Style.Margins.defaultInsets.left + Style.Margins.defaultInsets.right
                    )
                ]
        )
    }

    private func setupUI() {
        DesignSystemColor.allPacks.forEach {
            let colorView = ColorPaletteView()
            colorView.set(colorPack: $0)
            rootStackView.addArrangedSubview(colorView)
            rootStackView.addArrangedSubview(spacer(5))
        }
    }
}
