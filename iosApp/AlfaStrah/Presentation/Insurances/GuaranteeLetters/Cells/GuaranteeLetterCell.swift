//
//  GuaranteeLetterCell.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 07.04.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class GuaranteeLetterCell: UITableViewCell
{
    @IBOutlet private var clinicNameLabel: UILabel!
    @IBOutlet private var issueDateLabel: UILabel!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var expirationDateLabel: UILabel!
    @IBOutlet private var downloadButtonContainer: UIView!
	@IBOutlet private var downloadImageView: UIImageView!

    private var downloadGuaranteeLetter: (() -> Void)?

    static let id: Reusable<GuaranteeLetterCell> = .fromClass()

    override func awakeFromNib()
    {
        super.awakeFromNib()

        clinicNameLabel <~ Style.Label.primaryCaption1
        expirationDateLabel <~ Style.Label.primaryHeadline3
        issueDateLabel <~ Style.Label.secondaryCaption1

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDownloadButton))
        downloadButtonContainer.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func onDownloadButton()
    {
        downloadGuaranteeLetter?()
    }

    struct DisplayedStrings
    {
        let clinicName: String
        let issuedOn: String
        let status: String?
        let validUntil: String?
        let download: String?

        func composeSearchString() -> String
        {
            let searchableStrings: [String?] = [
                clinicName,
                issuedOn,
                status,
                validUntil,
                download
            ]
            return searchableStrings
                .compactMap { $0 }
                .joined()
                .lowercased()
        }
    }

    static func getDisplayedStrings(for guaranteeLetter: GuaranteeLetter) -> DisplayedStrings
    {
        DisplayedStrings(
            clinicName: guaranteeLetter.clinicName,
            issuedOn: String(
                format: NSLocalizedString("guarantee_letter_issue_date", comment: ""),
                issueDateTimeFormatter.string(from: guaranteeLetter.issueDateTimeUtc)
            ),
            status: !guaranteeLetter.isActive
                ? guaranteeLetter.statusText
                : nil,
            validUntil: guaranteeLetter.isActive
                ? guaranteeLetter.expirationDateText
                : nil,
            download: guaranteeLetter.isActive
                ? NSLocalizedString("download_letter_of_guarantee", comment: "")
                : nil
        )
    }

    func configure(guaranteeLetter: GuaranteeLetter, downloadGuaranteeLetter: @escaping () -> Void)
    {
        let displayedStrings = Self.getDisplayedStrings(for: guaranteeLetter)

        clinicNameLabel.text = displayedStrings.clinicName

        issueDateLabel.text = displayedStrings.issuedOn

        expirationDateLabel.isHidden = displayedStrings.validUntil == nil
        expirationDateLabel.text = displayedStrings.validUntil

        statusLabel.isHidden = displayedStrings.status == nil
        statusLabel.text = displayedStrings.status

        downloadButtonContainer.isHidden = displayedStrings.download == nil
        self.downloadGuaranteeLetter = downloadGuaranteeLetter
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		downloadImageView.image = .Icons.download.resized(newWidth: 16)?.tintedImage(withColor: .Icons.iconAccent)
	}
}

private let issueDateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy HH:mm"
    formatter.locale = AppLocale.currentLocale
    return formatter
}()
