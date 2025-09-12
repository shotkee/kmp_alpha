//
//  DmsCostRecoveryBankSearchTableCell.swift
//  AlfaStrah
//
//  Created by vit on 26.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DmsCostRecoveryBankSearchTableCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var bikLabel: UILabel!
    @IBOutlet private var selectionImageView: UIImageView!
    
    static let id: Reusable<DmsCostRecoveryBankSearchTableCell> = .fromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        selectionImageView.isHidden = true
    }
    
    func configure(
        searchString: String,
        bank: DmsCostRecoveryBank
    ) {
        let attributedTitle = NSMutableAttributedString(string: bank.title, attributes: [.font: Style.Font.caption2])
        attributedTitle.applyBold(searchString)
        titleLabel.attributedText = attributedTitle
        
        let attributedBik = NSMutableAttributedString(string: bank.bik, attributes: [.font: Style.Font.text])
        
        let prefixBik = NSMutableAttributedString(
            string: NSLocalizedString("dms_cost_recovery_bank_bik", comment: ""),
            attributes: [.font: Style.Font.text]
        )
        attributedBik.applyBold(searchString)
        prefixBik.append(attributedBik)
        bikLabel.attributedText = prefixBik
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectionImageView.isHidden = !selected
    }
}
