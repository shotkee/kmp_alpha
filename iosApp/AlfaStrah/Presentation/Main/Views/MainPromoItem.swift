//
//  MainPromosView.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 11/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class MainPromoItem: UIView, ImageLoaderDependency {
    @IBOutlet private var promoImage: PromoImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var detailButton: RoundEdgeButton!
    private var input: Input!
    private var detailTap: ((NewsItemModel) -> Void)?
    var imageLoader: ImageLoader!

    @IBAction private func detailClick(_ sender: Any) {
        detailTap?(input.model)
    }

    struct Input {
        let model: NewsItemModel
    }

    func set(input: Input, action: @escaping (NewsItemModel) -> Void) {
        self.input = input
        detailTap = action
        setupUI()
    }

    private func setupUI() {
        titleLabel.text = input.model.title
        subtitleLabel.text = input.model.info
        promoImage.imageLoader = imageLoader
        detailButton.setTitle(input.model.actionTitle, for: .normal)
        if let iconImage = input.model.iconImage {
            promoImage.image = iconImage
        } else if let iconImageURL = input.model.iconImageURL, let url = URL(string: iconImageURL) {
            promoImage.placeholder = UIImage(named: "ico-context-alfa")
            promoImage.imageUrl = url
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        detailButton <~ Style.Button.whiteGrayButton
        titleLabel <~ Style.Label.primaryHeadline2
        subtitleLabel <~ Style.Label.secondaryText
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        detailButton <~ Style.Button.whiteGrayButton
    }
}
