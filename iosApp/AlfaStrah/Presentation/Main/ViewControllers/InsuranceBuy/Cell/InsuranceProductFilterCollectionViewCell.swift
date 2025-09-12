//
//  InsuranceProductFilterCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 24.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class InsuranceProductFilterCollectionViewCell: UICollectionViewCell {
    static let id: Reusable<InsuranceProductFilterCollectionViewCell> = .fromClass()
    private var titleLabel = UILabel()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView?.isOpaque = true
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            updateContentView()
        }
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        contentView.layer.borderColor = isSelected
            ? UIColor.clear.cgColor
            : UIColor.Stroke.strokeBorder.cgColor
    }
}

private extension InsuranceProductFilterCollectionViewCell {
    func setupUI() {
        setupContentView()
        setupTitleLabel()
    }
    
    private func updateContentView() {
        contentView.layer.borderColor = isSelected
            ? UIColor.clear.cgColor
            : UIColor.Stroke.strokeBorder.cgColor
        contentView.backgroundColor = isSelected
            ? .Background.backgroundAccent
            : .clear
        titleLabel.textColor = isSelected
            ? .Text.textContrast
            : .Text.textPrimary
    }
    
    func setupContentView() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.Stroke.strokeBorder.cgColor
    }
    
    func setupTitleLabel() {
        titleLabel <~ Style.Label.primaryText
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
}

extension InsuranceProductFilterCollectionViewCell {
    func configure(title: String) {
        titleLabel.text = title
    }
}
