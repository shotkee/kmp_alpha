//
//  DmsCostRecoveryConditionView.swift
//  AlfaStrah
//
//  Created by vit on 09.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryConditionView: UIView {
    @IBOutlet private var digitLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var digitContainerView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }
    
    private func commonSetup() {
        setupUI()
    }
    
    private func setupUI() {
        addSelfAsSubviewFromNib()
        
        titleLabel <~ Style.Label.primaryHeadline3
        descriptionLabel <~ Style.Label.secondaryText
        digitLabel <~ Style.Label.accentHeadline3

        digitContainerView.layer.masksToBounds = true
		digitContainerView.layer.cornerRadius = digitContainerView.frame.width * 0.5
        digitContainerView.layer.borderWidth = 1
		digitContainerView.layer.borderColor = UIColor.Background.backgroundAccent.cgColor
    }
    
    func configure(
        digit: String,
        title: String,
        description: String = ""
    ) {
        digitLabel.text = digit
        titleLabel.text = title
        descriptionLabel.text = description
        
        descriptionLabel.isHidden = description.isEmpty
    }
}
