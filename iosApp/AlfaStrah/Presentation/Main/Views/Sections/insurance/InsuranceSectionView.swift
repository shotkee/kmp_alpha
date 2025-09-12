//
//  InsuranceSectionView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class InsuranceSectionView: UIView {
    @IBOutlet private var typeLabel: UILabel!
    @IBOutlet private var renewCountLabel: RoundMarkLabel!
    @IBOutlet private var objectLabel: UILabel!
    @IBOutlet private var containerStackView: UIStackView!
    @IBOutlet private var arrowImageView: UIImageView!

    @IBAction private func sectionTap(_ sender: Any) {
        isOpen.toggle()
    }

    var isOpen: Bool = false {
        didSet {
            expande(isOpen)
        }
    }

    func set(type: String, object: String, renewCount: Int, children: [UIView], isOpen: Bool) {
        children.forEach(containerStackView.addArrangedSubview)
        typeLabel.text = type
        objectLabel.text = object
        renewCountLabel.isHidden = renewCount == 0
        if renewCount > 0 {
            renewCountLabel.configure(text: "\(renewCount)", size: 18, backgroundColor: .Background.backgroundAccent, style: Style.Label.contrastCaption1)
        }
        self.isOpen = isOpen
    }

    private func expande(_ open: Bool) {
        containerStackView.arrangedSubviews.forEach {
            $0.isHidden = !open
        }
        arrowImageView.transform = CGAffineTransform(rotationAngle: .pi / (open ? 2 : -2))
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        arrowImageView.tintColor = .Icons.iconPrimary
        typeLabel <~ Style.Label.primaryCaption1
        objectLabel <~ Style.Label.primaryHeadline1
    }
}
