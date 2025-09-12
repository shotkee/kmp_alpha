//
//  SosActionView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class SosActionView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!

    var tapCallback: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        backgroundColor = .Background.backgroundSecondary
        
        titleLabel <~ Style.Label.secondaryText
    }

    func set(
        title: String,
        icon: UIImage?,
        tapCallback: @escaping () -> Void
    ) {
        titleLabel.text = title
        iconImageView.image = icon
        self.tapCallback = tapCallback
    }
    
	func set(icon: UIImage?) {
		iconImageView.image = icon
	}

    @objc private func viewTap() {
        tapCallback?()
    }
}
