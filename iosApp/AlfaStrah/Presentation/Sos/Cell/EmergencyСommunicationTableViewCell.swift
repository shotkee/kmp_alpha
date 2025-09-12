//
//  EmergencyСommunicationTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

class EmergencyСommunicationTableViewCell: UITableViewCell {

    static let id: Reusable<EmergencyСommunicationTableViewCell> = .fromClass()
    
    // MARK: Outlets
    private var iconImageViewContainerView = UIView()
    private var iconImageView = UIImageView()
    private var titleLabel = UILabel()
    private var rightImageView = UIImageView()
    private var separatorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
    
    private func setupUI() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupIconImageViewContainerView()
        setupIconImageView()
        setupTitleLabel()
        setupRightImageView()
        setupSeparatorView()
    }
    
    private func setupIconImageViewContainerView() {
        iconImageViewContainerView.clipsToBounds = true
        iconImageViewContainerView.layer.cornerRadius = 10
        iconImageViewContainerView.backgroundColor = .Background.backgroundTertiary
        contentView.addSubview(iconImageViewContainerView)
        iconImageViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageViewContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconImageViewContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            iconImageViewContainerView.heightAnchor.constraint(equalToConstant: 40),
            iconImageViewContainerView.widthAnchor.constraint(
                equalTo: iconImageViewContainerView.heightAnchor,
                multiplier: 1
            )
        ])
    }
    
    private func setupIconImageView() {
        iconImageView.contentMode = .scaleAspectFill
        iconImageViewContainerView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: iconImageViewContainerView.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: iconImageViewContainerView.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: iconImageViewContainerView.trailingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: iconImageViewContainerView.bottomAnchor)
        ])
    }
    
    private func setupRightImageView() {
        contentView.addSubview(rightImageView)
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rightImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            rightImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            rightImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            rightImageView.heightAnchor.constraint(equalToConstant: 24),
            rightImageView.widthAnchor.constraint(
                equalTo: rightImageView.heightAnchor,
                multiplier: 1
            )
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel <~ Style.Label.primarySubhead
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 73),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25)
        ])
    }
    
    private func setupSeparatorView() {
        separatorView.backgroundColor = .Stroke.divider
        contentView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: iconImageViewContainerView.bottomAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

extension EmergencyСommunicationTableViewCell {
    func configure(
        item: SosEmergencyCommunicationItem,
		rightIconURL: URL?,
		iconURL: URL?,
        isLastItem: Bool
    ) {
        titleLabel.text = item.title
        
        separatorView.backgroundColor = isLastItem
            ? .clear
            : .Stroke.divider

        rightImageView.sd_setImage(
			with: rightIconURL,
            placeholderImage: .Icons.call.tintedImage(withColor: .Icons.iconAccentThemed)
        )
        
        iconImageView.sd_setImage(
			with: iconURL,
            completed: { [weak self] image, _, _, _ in
                
                self?.iconImageView.isHidden = image == nil
                self?.iconImageView.image = image
            }
        )
    }
}
