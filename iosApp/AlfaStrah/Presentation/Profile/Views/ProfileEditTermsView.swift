//
//  ProfileEditTermsView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/17/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class ProfileEditTermsView: UIView {
    @IBOutlet private var checkBoxButton: UIButton!

    var infoAction: (() -> Void)?
    var changeAction: ((Bool) -> Void)?
    var termsAccepted: Bool {
        checkBoxButton.isSelected
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        checkBoxButton.setImage(UIImage(named: "icoAgreeEmpty"), for: .normal)
        checkBoxButton.setImage(UIImage(named: "icoAgreeOk"), for: .selected)
    }

    @IBAction private func infoButtonTaped(_ sender: UIButton) {
        infoAction?()
    }

    @IBAction private func checkButtonTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        changeAction?(sender.isSelected)
    }
}
