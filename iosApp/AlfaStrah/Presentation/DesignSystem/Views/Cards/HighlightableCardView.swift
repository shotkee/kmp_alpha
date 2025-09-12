//
//  Highlightable Card View.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 21.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class HighlightableCardView: UIControl {
    override init(frame: CGRect) {
        super.init(frame: frame)

        updateHighlightedStateUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        updateHighlightedStateUI()
    }

    override var isHighlighted: Bool {
        didSet {
            if isEnabled {
                updateHighlightedStateUI()
            }
        }
    }

    private func updateHighlightedStateUI() {
        backgroundColor = isHighlighted
			? .Background.backgroundSecondary.withAlphaComponent(0.4)
            : .Background.backgroundSecondary
    }
}
