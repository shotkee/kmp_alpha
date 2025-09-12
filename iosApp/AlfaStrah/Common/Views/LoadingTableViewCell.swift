//
// LoadingTableViewCell
// AlfaStrah
//
// Created by Eugene Egorov on 14 January 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class LoadingTableViewCell: UITableViewCell {
    static let id: Reusable<LoadingTableViewCell> = .fromClass()

    private let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func animate(_ animated: Bool) {
        if animated {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.startAnimating()
        }
    }

    private func setup() {
        selectionStyle = .none
		
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear

        contentView.addSubview(activityIndicatorView)

		activityIndicatorView.color = .Icons.iconAccent
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 44).with(priority: .required - 1),
            activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
