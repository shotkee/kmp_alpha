//
//  ChatSearchResultCell.swift
//  AlfaStrah
//
//  Created by vit on 05.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class ChatSearchResultCell: UITableViewCell {
    static let id: Reusable<ChatSearchResultCell> = .fromClass()
    
    private let searchResultLabel = UILabel()
    private let timestampLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let contentStackView = UIStackView()
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
		contentStackView.backgroundColor = .Background.backgroundSecondary
        
        contentView.addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: contentStackView, in: contentView))
        
        contentStackView.addArrangedSubview(searchResultLabel)
        searchResultLabel <~ Style.Label.primaryText
        searchResultLabel.numberOfLines = 0
        
        contentStackView.addArrangedSubview(spacer(4))
        contentStackView.addArrangedSubview(timestampLabel)
        
        timestampLabel <~ Style.Label.secondarySubhead
        timestampLabel.numberOfLines = 0
        
        contentStackView.addArrangedSubview(spacer(16))
        contentStackView.addArrangedSubview(separator())
    }
    
    func configure(
        text: NSMutableAttributedString,
        date: Date
    ) {
        searchResultLabel.attributedText = text
        timestampLabel.text = AppLocale.chatDateString(date)
    }
}
