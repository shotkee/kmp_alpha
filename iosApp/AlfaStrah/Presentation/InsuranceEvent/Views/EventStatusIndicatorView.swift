//
//  EventStatusIndicatorView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class EventStatusIndicatorView: UIView, ImageLoaderDependency {
    @IBOutlet private var topLineView: UIView!
    @IBOutlet private var iconImageView: NetworkImageView!
    @IBOutlet private var bottomLineView: UIView!

    var imageLoader: ImageLoader!

    var isFirstItem = false {
        didSet { topLineView.isHidden = isFirstItem }
    }

    var isLastItem = false {
        didSet { bottomLineView.isHidden = isLastItem }
    }

    var active = false {
        didSet {
            iconImageView.backgroundColor = active
                ? Style.Color.Palette.green
                : .Background.backgroundAdditional
        }
    }

    var iconImageUrl: URL? {
        didSet {
            iconImageView.imageLoader = imageLoader
            iconImageView.imageUrl = iconImageUrl
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

		iconImageView.backgroundColor = .Background.backgroundSecondary
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        iconImageView.layer.cornerRadius = iconImageView.bounds.width / 2.0
        let image = iconImageView.image
        iconImageView.image = image?.withRenderingMode(.alwaysOriginal)
    }

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        addSelfAsSubviewFromNib()
    }
}
