//
// NotificationInfoMessageView
// AlfaStrah
//
// Created by Eugene Egorov on 22 November 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit

class NotificationInfoMessageView: UIView {
    private let contentStackView = UIStackView()
    private let dateLabel = UILabel()
    private let titleLabel = UILabel()
    private let contentLabel = UITextView()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(spacer(9))
        contentStackView.addArrangedSubview(dateLabel)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(contentLabel)
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .zero
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 15
        contentStackView.backgroundColor = .clear
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: contentStackView, in: self))
        
        dateLabel <~ Style.Label.secondaryCaption1
        
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.numberOfLines = 0
        
		contentLabel.backgroundColor = .clear
		contentLabel.isScrollEnabled = false
    }

    func set(date: Date, title: String, content: String?) {
        dateLabel.text = dateFormatter.string(from: date)
        titleLabel.text = title
		
		if let content {
			let mutableAttributedString = TextHelper.html(from: content).mutable
			let range = NSRange(location: 0, length: mutableAttributedString.length)
			mutableAttributedString.addAttributes(Style.TextAttributes.oldPrimaryText, range: range)
			contentLabel.attributedText = mutableAttributedString
			contentLabel.linkTextAttributes = Style.TextAttributes.link
		}
    }
}
