//
//  RoundedTopHeaderView.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 3/7/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class RoundedTopHeaderView: UIView {
    private enum Constants {
        static let cornerRadii = CGSize(width: 19, height: 19)
        static let insets = UIEdgeInsets(top: 24, left: 18, bottom: 0, right: 18)
    }

    private let headerLabel = UILabel()

    var title: String? {
        didSet {
            headerLabel.text = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        let fillConstraints = NSLayoutConstraint.fill(view: headerLabel, in: self, margins: Constants.insets)
        NSLayoutConstraint.activate(fillConstraints)
        headerLabel <~ Style.Label.primaryHeadline3
    }
}
