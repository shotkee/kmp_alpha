//
//  AppointmentsNoticeCell.swift
//  AlfaStrah
//
//  Created by vit on 18.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

class AppointmentsNoticeCell: UITableViewCell {
    static let id: Reusable<AppointmentsNoticeCell> = .fromClass()
    private let noticeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupNoticeLabel()
    }
    
    private func setupNoticeLabel() {
        noticeLabel.numberOfLines = 0
        contentView.addSubview(noticeLabel)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false

        let attributedText = (NSLocalizedString("clinic_appointments_banner_text", comment: "") <~ Style.TextAttributes.blackInfoSmallText).mutable
        attributedText.applyBold(
            NSLocalizedString("clinic_appointments_banner_highlighted_text", comment: "")
        )
        noticeLabel.attributedText = attributedText
        
        NSLayoutConstraint.activate([
            noticeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            noticeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            noticeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            noticeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
