//
//  StatusCardView.swift
//  AlfaStrah
//
//  Created by vit on 17.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class StatusCardView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
    
    private func setup() {
		backgroundColor = .Background.backgroundSecondary
        addSelfAsSubviewFromNib()
        
        titleLabel <~ Style.Label.primaryHeadline3
        descriptionLabel <~ Style.Label.secondaryHeadline3
    }
    
    func configure(
        title: String,
        description: String = "",
        iconImage: UIImage = UIImage(named: "small-icon-info-alert-template") ?? UIImage()
    ) {
        titleLabel.text = title
        descriptionLabel.text = description
		iconView.tintColor = .Icons.iconAccent
        iconView.image = iconImage

        descriptionLabel.isHidden = description.isEmpty
    }
    
    func update(title: String) {
        titleLabel.text = title
    }
}
