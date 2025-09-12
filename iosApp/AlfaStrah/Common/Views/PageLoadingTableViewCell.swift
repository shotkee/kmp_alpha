//
//  PageLoadingTableViewCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 04/09/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class PageLoadingTableViewCell: UITableViewCell {
	static let id: Reusable<PageLoadingTableViewCell> = .fromClass()
    static let cellHeight: CGFloat = 88

    private let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = Style.Color.main
        activityIndicatorView.hidesWhenStopped = false
        contentView.addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func startAnimating() {
        activityIndicatorView.startAnimating()
    }
}
