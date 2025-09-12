//
//  FontView.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 31.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//
import UIKit

class FontView: UIView {
    private let rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        addSubview(rootStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: self)
        )
    }

    func set(font: DesignSystemFont) {
        let fontExampleLabel = UILabel()

        let fontWeight = font.uiFont.fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.face) as? String ?? ""
        let fontSize = Int(font.uiFont.pointSize)

        fontExampleLabel.font = font.uiFont
        fontExampleLabel.text = font.title

        let weightTextLabel = createSubtextLabel(text: "Weight: " + fontWeight)
        let sizeTextLabel = createSubtextLabel(text: "Size: \(fontSize)")

        let descriptionLabel = createSubtextLabel(text: font.description)
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0

        rootStackView.addArrangedSubview(fontExampleLabel)
        rootStackView.addArrangedSubview(horizontalStackView)
        rootStackView.addArrangedSubview(descriptionLabel)

        horizontalStackView.addArrangedSubview(weightTextLabel)
        horizontalStackView.addArrangedSubview(sizeTextLabel)
    }

    private func createSubtextLabel(text: String) -> UILabel {
        let label: UILabel = .init()
        label.text = text
        label <~ Style.Label.secondaryCaption1
        return label
    }
}
