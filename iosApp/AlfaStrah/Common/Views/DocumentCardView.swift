//
//  DocumentCardView.swift
//  AlfaStrah
//
//  Created by vit on 10.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class DocumentCardView: UIControl {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!
    
    private var tapHandler: (() -> Void)?
    
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
        let view = addSelfAsSubviewFromNib()
		view.backgroundColor = .Background.backgroundSecondary
        
        view.isUserInteractionEnabled = false
        
        titleLabel <~ Style.Label.primaryHeadline3
        descriptionLabel <~ Style.Label.secondaryText
        
        addTarget(self, action: #selector(viewTap), for: .touchUpInside)
    }
    
    func configure(
        title: String,
        description: String? = nil,
        iconImage: UIImage,
        tapHandler: (() -> Void)? = nil
    ) {
        titleLabel.text = title
        descriptionLabel.text = description
        iconView.image = iconImage

        descriptionLabel.isHidden = description == nil
        
        self.tapHandler = tapHandler
    }
    
    @objc private func viewTap() {
        tapHandler?()
    }
}
