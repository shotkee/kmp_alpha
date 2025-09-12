//
// PromoImageView
// AlfaStrah
//
// Created by Eugene Egorov on 23 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class PromoImageView: UIView {
    private let imageView: NetworkImageView = NetworkImageView()

    @IBInspectable var imageBackgroundColor: UIColor? {
        get {
            imageView.backgroundColor
        }
        set {
            imageView.backgroundColor = newValue
        }
    }

    @IBInspectable var imageTintColor: UIColor? {
        get {
            imageView.tintColor
        }
        set {
            imageView.tintColor = newValue
        }
    }

    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    var placeholder: UIImage?

    var imageLoader: ImageLoader? {
        didSet {
            imageView.imageLoader = imageLoader
        }
    }

    var imageUrl: URL? {
        didSet {
            imageView.imageUrl = imageUrl
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFill
        clipsToBounds = true
        addSubview(imageView)

        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: imageView, in: self))
    }
}
