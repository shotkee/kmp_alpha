//
//  InsuranceBillPropertyView.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 16.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import UIKit

class InsuranceBillPropertyView: UIView {
    open override var intrinsicContentSize: CGSize {
        CGSize(width: .zero, height: 72.0)
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label <~ Style.Label.secondaryCaption1
        label.numberOfLines = 1
        return label
    }()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label <~ Style.Label.primaryHeadline3
        label.numberOfLines = 1
        return label
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    private let horizontalSeparator: UIView = {
        let view = UIView()
		view.backgroundColor = .Stroke.divider
        return view
    }()

    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        self.layoutMargins = .zero

        addSubview(nameLabel)
        addSubview(valueLabel)
        addSubview(imageView)
        addSubview(horizontalSeparator)

        doNotTranslateAutoresizingMaskIntoConstraints(
            nameLabel, valueLabel, imageView, horizontalSeparator
        )

        let views: [String: Any] = [
            "nameLabel": nameLabel,
            "valueLabel": valueLabel,
            "imageView": imageView,
        ]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-18-[nameLabel]-(>=0)-[imageView]-18-|",
            metrics: nil,
            views: views
        ))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-18-[valueLabel]-(>=0)-[imageView]-18-|",
            metrics: nil,
            views: views
        ))

        NSLayoutConstraint.fixWidth(view: imageView, constant: 24)
        NSLayoutConstraint.fixHeight(view: imageView, constant: 24)
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-18-[nameLabel(15)]-3-[valueLabel(18)]-18-|",
            metrics: nil,
            views: views
        ))

        NSLayoutConstraint.activate([
            horizontalSeparator.heightAnchor.constraint(equalToConstant: 1),
            horizontalSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            horizontalSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            horizontalSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }

    // MARK: API
	func set(name: String, value: String, icon: UIImage?) {
        nameLabel.text = name
        valueLabel.text = value
        imageView.image = icon
    }
}
