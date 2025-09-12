//
//  BackgroundButton
//  AlfaStrah
//
//  Created by Roman Churkin on 10/07/15.
//  Copyright (c) 2014 RMR. All rights reserved.
//

import UIKit

class BackgroundButton: UIButton {
    var normalBackgroundColor: UIColor = Style.Color.Palette.white {
        didSet {
            self.setBackgroundColor(normalBackgroundColor, forState: .normal)
        }
    }

    var highlightedBackgroundColor: UIColor = Style.Color.Palette.whiteGray {
        didSet {
            self.setBackgroundColor(highlightedBackgroundColor, forState: .highlighted)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        updateUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        updateUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        setBackgroundColor(normalBackgroundColor, forState: .normal)
        setBackgroundColor(highlightedBackgroundColor, forState: .highlighted)
    }
}
