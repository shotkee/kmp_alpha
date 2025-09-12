//
//  InsuranceCaseButtonView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 01/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class InsuranceCaseButtonView: UIView {
    @IBOutlet private var caseButton: RoundEdgeButton!
    private var sosTap: (() -> Void)?

    @IBAction private func buttonTap(_ sender: Any) {
        sosTap?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    func set(title: String, action: @escaping () -> Void) {
        caseButton.setTitle(title, for: .normal)
        sosTap = action
    }

    private func setupStyle() {
        caseButton <~ Style.RoundedButton.redBordered
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        caseButton <~ Style.RoundedButton.redBordered
    }
}
