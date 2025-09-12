//
//  ColorCardView.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 24.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class ColorPaletteView: UIView {
    private let rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 9
        return stack
    }()

    private let colorsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()

    private let hexLabel: UILabel = .init()
    private let titleLabel: UILabel = .init()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        backgroundColor = Style.Color.Palette.white

        rootStackView.addArrangedSubview(titleLabel)
        rootStackView.addArrangedSubview(colorsStackView)
        rootStackView.addArrangedSubview(hexLabel)

        addSubview(rootStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: self)
        )
        NSLayoutConstraint.fixHeight(view: colorsStackView, constant: 60)

        titleLabel <~ Style.Label.secondaryHeadline2
        hexLabel <~ Style.Label.secondaryText
    }

    func set(colorPack: [DesignSystemColor]) {
        colorsStackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }

        colorPack.forEach {
            let colorView = UIView()
            colorView.backgroundColor = $0.color
            colorsStackView.addArrangedSubview(colorView)
        }

        let titleText = colorPack.reduce("") { res, next  in
            res + next.title + "/"
        }.dropLast()
        titleLabel.text = String(titleText)

        let hexText = colorPack.reduce("") { res, next in
            res + "#" + next.color.hexRGB + "/"
        }.dropLast()
        hexLabel.text = String(hexText)
    }
}
